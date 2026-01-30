<?php

namespace App\Domain\Cancellations\Services;

use App\Domain\Cancellations\Models\Cancellation;
use App\Domain\Dispatch\Enums\DispatchJobStatus;
use App\Domain\Dispatch\Enums\DispatchPurpose;
use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Dispatch\Models\DispatchOffer;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Products\Services\InventoryService;
use App\Domain\Riders\Enums\RiderAvailabilityStatus;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Riders\Services\RiderStatsService;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Workflows\Models\WorkflowStep;
use App\Support\Exceptions\ConflictException;
use Illuminate\Support\Facades\DB;

class CancellationService
{
    public function __construct(
        private readonly EscrowService $escrowService,
        private readonly WalletService $walletService,
        private readonly InventoryService $inventoryService,
        private readonly RiderStatsService $riderStatsService,
    ) {
    }

    public function cancel(User $actor, Order $order, string $reason): Cancellation
    {
        return DB::transaction(function () use ($actor, $order, $reason): Cancellation {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === OrderStatus::Cancelled) {
                return Cancellation::query()->where('order_id', $locked->id)->firstOrFail();
            }

            $this->assertCancellationAllowedByWorkflow($locked);

            $penaltyAmount = 0.0;

            if ($actor->role === UserRole::Buyer) {
                $this->assertBuyerCanCancel($actor, $locked);
                $this->refundBuyer($locked, $actor->id);
                $this->inventoryService->restoreOrderStock($locked);
            } elseif ($actor->role === UserRole::Seller) {
                $this->assertSellerCanCancel($actor, $locked);
                $this->refundBuyer($locked, $actor->id);
                $this->inventoryService->restoreOrderStock($locked);
                $penaltyAmount = $this->applyPenalty($actor, (float) config('smartlink.cancellations.seller_penalty_amount', 0), $locked);
            } elseif ($actor->role === UserRole::Rider) {
                $this->assertRiderCanCancel($actor, $locked);
                $penaltyAmount = $this->applyPenalty($actor, (float) config('smartlink.cancellations.rider_penalty_amount', 0), $locked);
                $this->redispatch($locked, $actor);
            } else {
                throw new \RuntimeException('Unsupported role.');
            }

            $cancellation = Cancellation::create([
                'order_id' => $locked->id,
                'cancelled_by_user_id' => $actor->id,
                'reason' => $reason,
                'penalty_amount' => $penaltyAmount,
            ]);

            return $cancellation;
        });
    }

    private function assertBuyerCanCancel(User $buyer, Order $order): void
    {
        if ((int) $order->buyer_user_id !== (int) $buyer->id) {
            throw new \RuntimeException('Forbidden.');
        }

        if (! in_array($order->status, [OrderStatus::Placed, OrderStatus::Paid, OrderStatus::AcceptedBySeller], true)) {
            throw new \RuntimeException('Order can no longer be cancelled.');
        }
    }

    private function assertSellerCanCancel(User $seller, Order $order): void
    {
        if ((int) ($order->shop?->seller_user_id ?? 0) !== (int) $seller->id) {
            throw new \RuntimeException('Forbidden.');
        }

        if (! in_array($order->status, [OrderStatus::Placed, OrderStatus::Paid, OrderStatus::AcceptedBySeller], true)) {
            throw new \RuntimeException('Order can no longer be cancelled.');
        }
    }

    private function assertRiderCanCancel(User $rider, Order $order): void
    {
        $job = DispatchJob::query()
            ->where('order_id', $order->id)
            ->where('purpose', DispatchPurpose::Delivery->value)
            ->first();

        if (! $job || (int) $job->assigned_rider_user_id !== (int) $rider->id) {
            throw new \RuntimeException('Forbidden.');
        }

        if ($order->status !== OrderStatus::AssignedToRider) {
            throw new \RuntimeException('Order cannot be cancelled at this stage.');
        }
    }

    private function refundBuyer(Order $order, int $actorUserId): void
    {
        $hold = $order->escrowHold()->lockForUpdate()->first();
        if ($hold && in_array($hold->status, [EscrowStatus::Held, EscrowStatus::Frozen], true)) {
            $this->escrowService->refund($hold, $actorUserId);
        }

        $order->forceFill([
            'status' => OrderStatus::Cancelled,
            'payment_status' => OrderPaymentStatus::Refunded,
        ])->save();

        $this->appendHistory($order, OrderStatus::Cancelled, $actorUserId);

        $job = DispatchJob::query()
            ->where('order_id', $order->id)
            ->where('purpose', DispatchPurpose::Delivery->value)
            ->first();

        if ($job) {
            $job->forceFill(['status' => DispatchJobStatus::Cancelled])->save();
            DispatchOffer::query()
                ->where('dispatch_job_id', $job->id)
                ->whereIn('offer_status', ['sent', 'seen'])
                ->update(['offer_status' => 'expired']);
        }
    }

    private function applyPenalty(User $user, float $amount, Order $order): float
    {
        $amount = round($amount, 2);
        if ($amount <= 0) {
            return 0.0;
        }

        try {
            $wallet = $this->walletService->walletFor($user);
            $this->walletService->record(
                $wallet,
                WalletTransactionType::Fee,
                WalletTransactionDirection::Out,
                $amount,
                "order:{$order->id}:cancellation:penalty",
                relatedEntityType: 'orders',
                relatedEntityId: $order->id,
                meta: ['actor_user_id' => $user->id],
            );

            return $amount;
        } catch (\RuntimeException $e) {
            return 0.0;
        }
    }

    private function redispatch(Order $order, User $rider): void
    {
        /** @var DispatchJob $job */
        $job = DispatchJob::query()
            ->where('order_id', $order->id)
            ->where('purpose', DispatchPurpose::Delivery->value)
            ->lockForUpdate()
            ->firstOrFail();

        $job->forceFill([
            'status' => DispatchJobStatus::Broadcasting,
            'assigned_rider_user_id' => null,
        ])->save();

        DispatchOffer::query()
            ->where('dispatch_job_id', $job->id)
            ->where('offer_status', 'accepted')
            ->update(['offer_status' => 'expired']);

        $order->forceFill(['status' => OrderStatus::Dispatching])->save();
        $this->appendHistory($order, OrderStatus::Dispatching, $rider->id);

        RiderAvailability::query()
            ->where('rider_user_id', $rider->id)
            ->update(['status' => RiderAvailabilityStatus::Available->value, 'last_seen_at' => now()]);

        $this->riderStatsService->refresh($rider->id);

        dispatch(new \App\Domain\Dispatch\Jobs\BroadcastDispatchOffersJob($job->id, 'fallback'));
    }

    private function appendHistory(Order $order, OrderStatus $status, ?int $changedByUserId): void
    {
        OrderStatusHistory::create([
            'order_id' => $order->id,
            'status' => $status->value,
            'changed_by_user_id' => $changedByUserId,
        ]);
    }

    private function assertCancellationAllowedByWorkflow(Order $order): void
    {
        if (! $order->workflow_id || ! $order->workflow_step_id) {
            return;
        }

        $triggerSequence = WorkflowStep::query()
            ->where('workflow_id', $order->workflow_id)
            ->where('is_dispatch_trigger', true)
            ->value('sequence');

        if (! $triggerSequence) {
            return;
        }

        $currentSequence = WorkflowStep::query()->whereKey($order->workflow_step_id)->value('sequence');
        if ($currentSequence && (int) $currentSequence >= (int) $triggerSequence) {
            throw new ConflictException('Order can no longer be cancelled.');
        }
    }
}
