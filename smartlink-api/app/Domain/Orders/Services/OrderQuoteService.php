<?php

namespace App\Domain\Orders\Services;

use App\Domain\Delivery\Services\DeliveryFeeService;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderQuoteStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Enums\OrderWorkflowState;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Shops\Enums\ShopType;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use App\Domain\Workflows\Models\WorkflowStep;
use App\Support\Exceptions\ConflictException;
use Illuminate\Support\Facades\DB;

class OrderQuoteService
{
    public function __construct(
        private readonly WalletService $walletService,
        private readonly EscrowService $escrowService,
        private readonly DeliveryFeeService $deliveryFeeService,
    ) {
    }

    public function send(User $seller, Order $order, float $amount, ?int $etaMin = null, ?int $etaMax = null): Order
    {
        if ($amount <= 0) {
            throw new \InvalidArgumentException('Invalid quote amount.');
        }

        return DB::transaction(function () use ($seller, $order, $amount, $etaMin, $etaMax): Order {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ((int) ($locked->shop?->seller_user_id ?? 0) !== (int) $seller->id) {
                throw new \RuntimeException('Forbidden.');
            }

            if ($locked->service_type !== ShopType::Repair) {
                throw new \RuntimeException('Quotes are only supported for repair orders.');
            }

            if ($locked->quote_status === OrderQuoteStatus::Approved) {
                return $locked;
            }

            $locked->forceFill([
                'quoted_amount' => round($amount, 2),
                'quote_status' => OrderQuoteStatus::Sent,
                'quote_sent_at' => now(),
                'workflow_eta_min' => $etaMin ?? $locked->workflow_eta_min,
                'workflow_eta_max' => $etaMax ?? $locked->workflow_eta_max,
            ])->save();

            return $locked->fresh(['workflow', 'workflowStep', 'workflowEvents.toStep', 'workflowEvents.fromStep']);
        });
    }

    public function approve(User $buyer, Order $order): Order
    {
        $this->walletService->requireVerifiedForWallet($buyer);

        return DB::transaction(function () use ($buyer, $order): Order {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ((int) $locked->buyer_user_id !== (int) $buyer->id) {
                throw new \RuntimeException('Forbidden.');
            }

            if ($locked->service_type !== ShopType::Repair) {
                throw new \RuntimeException('Quote approval is only supported for repair orders.');
            }

            if ($locked->quote_status === OrderQuoteStatus::Approved) {
                return $locked->fresh(['escrowHold']);
            }

            if ($locked->quote_status !== OrderQuoteStatus::Sent || ! $locked->quoted_amount) {
                throw new ConflictException('No quote available to approve.');
            }

            $deliveryFeeBreakdown = $this->deliveryFeeService->calculateForZone((int) $locked->zone_id);
            $deliveryFee = (float) $deliveryFeeBreakdown['delivery_fee'];
            $riderShare = (float) $deliveryFeeBreakdown['rider_share'];
            $platformFee = (float) $deliveryFeeBreakdown['platform_fee'];

            $subtotal = (float) $locked->quoted_amount;
            $total = $subtotal + $deliveryFee;

            $locked->forceFill([
                'subtotal_amount' => $subtotal,
                'delivery_fee_amount' => $deliveryFee,
                'rider_share_amount' => $riderShare,
                'platform_fee_amount' => $platformFee,
                'total_amount' => $total,
                'quote_status' => OrderQuoteStatus::Approved,
                'quote_approved_at' => now(),
            ])->save();

            if ($locked->workflow_step_id) {
                $step = WorkflowStep::query()->whereKey($locked->workflow_step_id)->first();
                if ($step && $step->step_key === 'awaiting_approval') {
                    $locked->forceFill(['workflow_state' => OrderWorkflowState::InProgress])->save();
                }
            }

            if (! $locked->escrowHold()->exists()) {
                $buyerWallet = $this->walletService->walletFor($buyer);

                $this->walletService->record(
                    $buyerWallet,
                    WalletTransactionType::Hold,
                    WalletTransactionDirection::Out,
                    $total,
                    "order:{$locked->id}:hold",
                    relatedEntityType: 'orders',
                    relatedEntityId: $locked->id,
                    meta: ['actor_user_id' => $buyer->id],
                );

                $this->escrowService->createHold(
                    $locked,
                    $buyerWallet->id,
                    (int) ($locked->shop?->seller_user_id ?? 0),
                    $total,
                );
            }

            if ($locked->payment_status !== OrderPaymentStatus::Paid) {
                $locked->forceFill([
                    'status' => OrderStatus::Paid,
                    'payment_status' => OrderPaymentStatus::Paid,
                ])->save();
                $this->appendHistory($locked, OrderStatus::Paid, $buyer->id);
            }

            return $locked->fresh(['escrowHold']);
        });
    }

    public function reject(User $buyer, Order $order): Order
    {
        return DB::transaction(function () use ($buyer, $order): Order {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ((int) $locked->buyer_user_id !== (int) $buyer->id) {
                throw new \RuntimeException('Forbidden.');
            }

            if ($locked->service_type !== ShopType::Repair) {
                throw new \RuntimeException('Quote rejection is only supported for repair orders.');
            }

            if ($locked->quote_status !== OrderQuoteStatus::Sent) {
                throw new ConflictException('No quote available to reject.');
            }

            $locked->forceFill([
                'quote_status' => OrderQuoteStatus::Rejected,
            ])->save();

            if ($locked->workflow_step_id) {
                $step = WorkflowStep::query()->whereKey($locked->workflow_step_id)->first();
                if ($step && $step->step_key === 'awaiting_approval') {
                    $locked->forceFill(['workflow_state' => OrderWorkflowState::Blocked])->save();
                }
            }

            return $locked;
        });
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
