<?php

namespace App\Domain\Disputes\Controllers;

use App\Domain\Disputes\Enums\DisputeResolution;
use App\Domain\Disputes\Enums\DisputeStatus;
use App\Domain\Disputes\Models\Dispute;
use App\Domain\Disputes\Requests\AdminResolveDisputeRequest;
use App\Domain\Disputes\Resources\DisputeResource;
use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Fraud\Services\FraudService;
use App\Domain\Notifications\Jobs\SendPushNotificationJob;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Products\Services\InventoryService;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Support\Facades\DB;

class AdminDisputeController
{
    public function __construct(
        private readonly EscrowService $escrowService,
        private readonly WalletService $walletService,
        private readonly FraudService $fraudService,
        private readonly InventoryService $inventoryService,
    ) {
    }

    public function resolve(AdminResolveDisputeRequest $request, Order $order)
    {
        $admin = $request->user();
        $data = $request->validated();

        /** @var Dispute|null $dispute */
        $dispute = Dispute::query()->where('order_id', $order->id)->first();
        if (! $dispute) {
            return response()->json(['message' => 'Dispute not found.'], 404);
        }

        $resolution = DisputeResolution::from($data['resolution']);

        $resolved = DB::transaction(function () use ($order, $dispute, $admin, $resolution, $data) {
            /** @var Dispute $lockedDispute */
            $lockedDispute = Dispute::query()->whereKey($dispute->id)->lockForUpdate()->firstOrFail();

            if ($lockedDispute->status === DisputeStatus::Resolved) {
                return $lockedDispute;
            }

            /** @var Order $lockedOrder */
            $lockedOrder = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            $hold = $lockedOrder->escrowHold()->lockForUpdate()->firstOrFail();

            if ($resolution === DisputeResolution::PaySeller) {
                if ($hold->status === EscrowStatus::Held || $hold->status === EscrowStatus::Frozen) {
                    $this->escrowService->release($hold, $admin->id);
                }

                $lockedOrder->forceFill(['status' => OrderStatus::Confirmed])->save();
                $this->appendHistory($lockedOrder, OrderStatus::Confirmed, $admin->id);
            } elseif ($resolution === DisputeResolution::PartialRefund) {
                $refundAmount = (float) ($data['partial_refund_amount'] ?? 0);
                if ($refundAmount <= 0 || $refundAmount >= (float) $hold->amount) {
                    throw new \RuntimeException('Invalid partial_refund_amount.');
                }

                $buyerWallet = $hold->buyerWalletAccount()->lockForUpdate()->firstOrFail();

                $this->walletService->record(
                    $buyerWallet,
                    WalletTransactionType::Refund,
                    WalletTransactionDirection::In,
                    $refundAmount,
                    "escrow:order:{$lockedOrder->id}:partial_refund",
                    relatedEntityType: 'orders',
                    relatedEntityId: $lockedOrder->id,
                    meta: ['actor_user_id' => $admin->id],
                );

                $remaining = (float) $hold->amount - $refundAmount;
                $riderAmount = min((float) $lockedOrder->rider_share_amount, $remaining);
                $remaining -= $riderAmount;
                $platformAmount = min((float) $lockedOrder->platform_fee_amount, $remaining);
                $remaining -= $platformAmount;
                $sellerAmount = min((float) $lockedOrder->subtotal_amount, $remaining);

                $this->escrowService->releaseWithBreakdown(
                    $hold,
                    $hold->seller()->firstOrFail(),
                    $sellerAmount,
                    $lockedOrder->dispatchJob?->assigned_rider_user_id,
                    $riderAmount,
                    (int) (config('smartlink.platform.user_id') ?? 0) ?: null,
                    $platformAmount,
                    $admin->id,
                );

                $lockedOrder->forceFill(['status' => OrderStatus::Confirmed])->save();
                $this->appendHistory($lockedOrder, OrderStatus::Confirmed, $admin->id);
            } else {
                // refund_buyer / penalize_* -> refund buyer
                if ($hold->status === EscrowStatus::Held || $hold->status === EscrowStatus::Frozen) {
                    $this->escrowService->refund($hold, $admin->id);
                }

                $lockedOrder->forceFill([
                    'status' => OrderStatus::Cancelled,
                    'payment_status' => OrderPaymentStatus::Refunded,
                ])->save();

                $this->appendHistory($lockedOrder, OrderStatus::Cancelled, $admin->id);
                $this->inventoryService->restoreOrderStock($lockedOrder);
            }

            $lockedDispute->forceFill([
                'status' => DisputeStatus::Resolved,
                'resolved_by_admin_id' => $admin->id,
                'resolution' => $resolution,
            ])->save();

            return $lockedDispute->fresh();
        });

        $buyerId = (int) $order->buyer_user_id;
        $sellerId = (int) ($order->shop?->seller_user_id ?? 0);

        if ($buyerId > 0) {
            dispatch(new SendPushNotificationJob(
                $buyerId,
                'Dispute resolved',
                'Your dispute has been resolved.',
                ['order_id' => $order->id, 'resolution' => $resolution->value],
            ));
        }

        if ($sellerId > 0) {
            dispatch(new SendPushNotificationJob(
                $sellerId,
                'Dispute resolved',
                'A dispute has been resolved.',
                ['order_id' => $order->id, 'resolution' => $resolution->value],
            ));
        }

        if ($resolution === DisputeResolution::PaySeller) {
            $buyer = $order->buyer()->first();
            if ($buyer) {
                $this->fraudService->recordDisputeStrike($buyer);
            }
        }

        return new DisputeResource($resolved);
    }

    private function appendHistory(Order $order, OrderStatus $status, ?int $changedByUserId): void
    {
        OrderStatusHistory::create([
            'order_id' => $order->id,
            'status' => $status->value,
            'changed_by_user_id' => $changedByUserId,
        ]);
    }
}
