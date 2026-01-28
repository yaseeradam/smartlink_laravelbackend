<?php

namespace App\Domain\Escrow\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Escrow\Enums\PayoutProvider;
use App\Domain\Escrow\Enums\PayoutStatus;
use App\Domain\Escrow\Models\EscrowHold;
use App\Domain\Escrow\Models\Payout;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Support\Facades\DB;

class EscrowService
{
    public function __construct(
        private readonly WalletService $walletService,
        private readonly AuditLogger $auditLogger,
    ) {}

    public function createHold(Order $order, int $buyerWalletAccountId, int $sellerUserId, float $amount): EscrowHold
    {
        $hold = EscrowHold::firstOrCreate(
            ['order_id' => $order->id],
            [
                'buyer_wallet_account_id' => $buyerWalletAccountId,
                'seller_user_id' => $sellerUserId,
                'amount' => $amount,
                'status' => EscrowStatus::Held,
                'hold_expires_at' => null,
            ],
        );

        if ($hold->wasRecentlyCreated) {
            $this->auditLogger->log(null, 'escrow.hold.created', $hold, [
                'order_id' => $order->id,
                'amount' => $amount,
            ]);
        }

        return $hold;
    }

    public function freeze(EscrowHold $hold): EscrowHold
    {
        if ($hold->status === EscrowStatus::Frozen) {
            return $hold;
        }

        $hold->forceFill(['status' => EscrowStatus::Frozen])->save();
        $this->auditLogger->log(null, 'escrow.frozen', $hold, ['order_id' => $hold->order_id]);

        return $hold->fresh();
    }

    public function release(EscrowHold $hold, ?int $actorUserId = null): EscrowHold
    {
        return DB::transaction(function () use ($hold, $actorUserId) {
            /** @var EscrowHold $locked */
            $locked = EscrowHold::query()->whereKey($hold->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === EscrowStatus::Released) {
                return $locked;
            }

            if ($locked->status !== EscrowStatus::Held) {
                throw new \RuntimeException('Escrow is not releasable.');
            }

            /** @var Order $order */
            $order = Order::query()->whereKey($locked->order_id)->firstOrFail();

            /** @var User $seller */
            $seller = User::query()->whereKey($locked->seller_user_id)->firstOrFail();

            $sellerAmount = (float) $order->subtotal_amount;
            $riderAmount = (float) $order->rider_share_amount;
            $platformAmount = (float) $order->platform_fee_amount;

            $riderUserId = $order->dispatchJob?->assigned_rider_user_id;
            if (! $riderUserId) {
                $riderAmount = 0;
            }

            $platformUserId = (int) (config('smartlink.platform.user_id') ?? 0);
            if ($platformUserId <= 0) {
                $platformAmount = 0;
            }

            $remaining = (float) $locked->amount - $riderAmount - $platformAmount;
            if ($remaining < 0) {
                $remaining = 0;
            }
            if ($sellerAmount > $remaining) {
                $sellerAmount = $remaining;
            }

            $this->releaseWithBreakdown(
                $locked,
                $seller,
                $sellerAmount,
                $riderUserId ? (int) $riderUserId : null,
                $riderAmount,
                $platformUserId > 0 ? $platformUserId : null,
                $platformAmount,
                $actorUserId,
            );

            return $locked->fresh();
        });
    }

    public function releaseWithBreakdown(
        EscrowHold $hold,
        User $seller,
        float $sellerAmount,
        ?int $riderUserId,
        float $riderAmount,
        ?int $platformUserId,
        float $platformAmount,
        ?int $actorUserId = null,
    ): EscrowHold {
        /** @var EscrowHold $locked */
        $locked = EscrowHold::query()->whereKey($hold->id)->lockForUpdate()->firstOrFail();

        if ($locked->status === EscrowStatus::Released) {
            return $locked;
        }

        if ($locked->status !== EscrowStatus::Held) {
            throw new \RuntimeException('Escrow is not releasable.');
        }

        /** @var Order $order */
        $order = Order::query()->whereKey($locked->order_id)->firstOrFail();

        if ($sellerAmount > 0) {
            $sellerWallet = $this->walletService->walletFor($seller);
            $this->walletService->record(
                $sellerWallet,
                WalletTransactionType::Release,
                WalletTransactionDirection::In,
                $sellerAmount,
                "escrow:order:{$order->id}:release",
                relatedEntityType: 'orders',
                relatedEntityId: $order->id,
                meta: ['actor_user_id' => $actorUserId],
            );
        }

        if ($riderUserId && $riderAmount > 0) {
            $rider = User::query()->whereKey($riderUserId)->first();
            if ($rider) {
                $riderWallet = $this->walletService->walletFor($rider);
                $this->walletService->record(
                    $riderWallet,
                    WalletTransactionType::Release,
                    WalletTransactionDirection::In,
                    $riderAmount,
                    "escrow:order:{$order->id}:rider:release",
                    relatedEntityType: 'orders',
                    relatedEntityId: $order->id,
                    meta: ['actor_user_id' => $actorUserId],
                );
            }
        }

        if ($platformUserId && $platformAmount > 0) {
            $platform = User::query()->whereKey($platformUserId)->first();
            if ($platform) {
                $platformWallet = $this->walletService->walletFor($platform);
                $this->walletService->record(
                    $platformWallet,
                    WalletTransactionType::Fee,
                    WalletTransactionDirection::In,
                    $platformAmount,
                    "escrow:order:{$order->id}:platform:fee",
                    relatedEntityType: 'orders',
                    relatedEntityId: $order->id,
                    meta: ['actor_user_id' => $actorUserId],
                );
            }
        }

        if ($sellerAmount > 0) {
            Payout::firstOrCreate(
                ['order_id' => $order->id],
                [
                    'seller_user_id' => $seller->id,
                    'amount' => $sellerAmount,
                    'status' => PayoutStatus::Pending,
                    'provider' => PayoutProvider::Paystack,
                    'provider_ref' => null,
                ],
            );
        }

        $locked->forceFill(['status' => EscrowStatus::Released])->save();
        $this->auditLogger->log($actorUserId, 'escrow.released', $locked, ['order_id' => $locked->order_id]);

        return $locked->fresh();
    }

    public function refund(EscrowHold $hold, ?int $actorUserId = null): EscrowHold
    {
        return DB::transaction(function () use ($hold, $actorUserId) {
            /** @var EscrowHold $locked */
            $locked = EscrowHold::query()->whereKey($hold->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === EscrowStatus::Refunded) {
                return $locked;
            }

            if (! in_array($locked->status, [EscrowStatus::Held, EscrowStatus::Frozen], true)) {
                throw new \RuntimeException('Escrow is not refundable.');
            }

            /** @var Order $order */
            $order = Order::query()->whereKey($locked->order_id)->firstOrFail();

            $buyerWallet = $locked->buyerWalletAccount()->lockForUpdate()->firstOrFail();

            $this->walletService->record(
                $buyerWallet,
                WalletTransactionType::Refund,
                WalletTransactionDirection::In,
                (float) $locked->amount,
                "escrow:order:{$order->id}:refund",
                relatedEntityType: 'orders',
                relatedEntityId: $order->id,
                meta: ['actor_user_id' => $actorUserId],
            );

            $locked->forceFill(['status' => EscrowStatus::Refunded])->save();
            $this->auditLogger->log($actorUserId, 'escrow.refunded', $locked, ['order_id' => $locked->order_id]);

            return $locked->fresh();
        });
    }
}
