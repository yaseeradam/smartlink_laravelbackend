<?php

namespace App\Domain\Orders\Services;

use App\Domain\Disputes\Enums\DisputeStatus;
use App\Domain\Disputes\Models\Dispute;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Delivery\Services\DeliveryFeeService;
use App\Domain\Fraud\Services\FraudService;
use App\Domain\Orders\Enums\OrderWorkflowState;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Enums\OrderKind;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderItem;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Orders\Models\OrderWorkflowEvent;
use App\Domain\Products\Enums\ProductStatus;
use App\Domain\Products\Models\Product;
use App\Domain\Shops\Enums\ShopType;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use App\Domain\Workflows\Models\WorkflowStep;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use App\Domain\Zones\Enums\ZoneStatus;
use Illuminate\Support\Facades\DB;

class OrderService
{
    public function __construct(
        private readonly WalletService $walletService,
        private readonly EscrowService $escrowService,
        private readonly DeliveryFeeService $deliveryFeeService,
        private readonly FraudService $fraudService,
    ) {
    }

    /**
     * @param  list<array{product_id:int, qty:int}>  $items
     */
    public function placeOrder(User $buyer, int $shopId, string $deliveryAddressText, array $items): Order
    {
        $this->walletService->requireVerifiedForWallet($buyer);

        return DB::transaction(function () use ($buyer, $shopId, $deliveryAddressText, $items): Order {
            /** @var Shop $shop */
            $shop = Shop::query()->whereKey($shopId)->firstOrFail();

            /** @var Zone $zone */
            $zone = Zone::query()->whereKey($shop->zone_id)->firstOrFail();
            if (! $zone->is_active || $zone->status === ZoneStatus::Paused) {
                throw new \RuntimeException('Zone is paused. Orders are not allowed.');
            }

            $buyerHomeZoneId = UserZone::query()
                ->where('user_id', $buyer->id)
                ->where('type', 'home')
                ->value('zone_id');

            if (! $buyerHomeZoneId) {
                throw new \RuntimeException('Home zone is required before placing orders.');
            }

            if ((int) $buyerHomeZoneId !== (int) $shop->zone_id) {
                throw new \RuntimeException('Order zone mismatch. This shop is outside your home zone.');
            }

            $order = Order::create([
                'buyer_user_id' => $buyer->id,
                'shop_id' => $shop->id,
                'order_kind' => OrderKind::Product,
                'service_type' => $shop->shop_type ?? ShopType::Retail,
                'workflow_id' => $shop->default_workflow_id,
                'zone_id' => $shop->zone_id,
                'subtotal_amount' => 0,
                'delivery_fee_amount' => 0,
                'total_amount' => 0,
                'status' => OrderStatus::Placed,
                'payment_status' => OrderPaymentStatus::Pending,
                'delivery_address_text' => $deliveryAddressText,
            ]);

            $this->appendHistory($order, OrderStatus::Placed, $buyer->id);

            $subtotal = 0.0;

            foreach ($items as $item) {
                $productId = (int) $item['product_id'];
                $qty = (int) $item['qty'];

                if ($qty <= 0) {
                    throw new \InvalidArgumentException('Invalid quantity.');
                }

                /** @var Product $product */
                $product = Product::query()->whereKey($productId)->lockForUpdate()->firstOrFail();

                if ((int) $product->shop_id !== (int) $shop->id) {
                    throw new \RuntimeException('Product does not belong to the selected shop.');
                }

                if ($product->status !== ProductStatus::Active) {
                    throw new \RuntimeException('Product is not available.');
                }

                if ($product->stock_qty < $qty) {
                    throw new \RuntimeException('Insufficient stock for product: '.$product->name);
                }

                $lineTotal = (float) $product->price * $qty;
                $subtotal += $lineTotal;

                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'qty' => $qty,
                    'unit_price' => $product->price,
                    'line_total' => $lineTotal,
                ]);

                $product->forceFill(['stock_qty' => $product->stock_qty - $qty])->save();
                if ($product->stock_qty <= 0) {
                    $product->forceFill(['status' => ProductStatus::OutOfStock])->save();
                }
            }

            $deliveryFee = 0.0;
            $deliveryFeeBreakdown = $this->deliveryFeeService->calculateForZone((int) $shop->zone_id);
            $deliveryFee = (float) $deliveryFeeBreakdown['delivery_fee'];
            $riderShare = (float) $deliveryFeeBreakdown['rider_share'];
            $platformFee = (float) $deliveryFeeBreakdown['platform_fee'];
            $total = $subtotal + $deliveryFee;

            $this->fraudService->checkNewAccountOrderLimit($buyer, $total);

            $order->forceFill([
                'subtotal_amount' => $subtotal,
                'delivery_fee_amount' => $deliveryFee,
                'rider_share_amount' => $riderShare,
                'platform_fee_amount' => $platformFee,
                'total_amount' => $total,
                'delivery_otp_required' => (bool) config('smartlink.delivery.otp_required', false),
            ])->save();

            $buyerWallet = $this->walletService->walletFor($buyer);

            $this->walletService->record(
                $buyerWallet,
                WalletTransactionType::Hold,
                WalletTransactionDirection::Out,
                $total,
                "order:{$order->id}:hold",
                relatedEntityType: 'orders',
                relatedEntityId: $order->id,
                meta: ['actor_user_id' => $buyer->id],
            );

            $this->escrowService->createHold(
                $order,
                $buyerWallet->id,
                (int) $shop->seller_user_id,
                $total,
            );

            $order->forceFill([
                'status' => OrderStatus::Paid,
                'payment_status' => OrderPaymentStatus::Paid,
            ])->save();

            $this->appendHistory($order, OrderStatus::Paid, $buyer->id);

            return $order->fresh(['items', 'shop', 'zone', 'escrowHold']);
        });
    }

    public function placeServiceOrder(User $buyer, int $shopId, string $deliveryAddressText, string $serviceType, ?string $issueDescription = null): Order
    {
        return DB::transaction(function () use ($buyer, $shopId, $deliveryAddressText, $serviceType, $issueDescription): Order {
            /** @var Shop $shop */
            $shop = Shop::query()->whereKey($shopId)->firstOrFail();

            /** @var Zone $zone */
            $zone = Zone::query()->whereKey($shop->zone_id)->firstOrFail();
            if (! $zone->is_active || $zone->status === ZoneStatus::Paused) {
                throw new \RuntimeException('Zone is paused. Orders are not allowed.');
            }

            $buyerHomeZoneId = UserZone::query()
                ->where('user_id', $buyer->id)
                ->where('type', 'home')
                ->value('zone_id');

            if (! $buyerHomeZoneId) {
                throw new \RuntimeException('Home zone is required before placing orders.');
            }

            if ((int) $buyerHomeZoneId !== (int) $shop->zone_id) {
                throw new \RuntimeException('Order zone mismatch. This shop is outside your home zone.');
            }

            if ($serviceType === ShopType::Repair->value && ! $issueDescription) {
                throw new \RuntimeException('Issue description is required for repair orders.');
            }

            $order = Order::create([
                'buyer_user_id' => $buyer->id,
                'shop_id' => $shop->id,
                'order_kind' => OrderKind::Service,
                'service_type' => ShopType::tryFrom($serviceType) ?? ShopType::Retail,
                'workflow_id' => $shop->default_workflow_id,
                'zone_id' => $shop->zone_id,
                'subtotal_amount' => 0,
                'delivery_fee_amount' => 0,
                'rider_share_amount' => 0,
                'platform_fee_amount' => 0,
                'total_amount' => 0,
                'status' => OrderStatus::Placed,
                'payment_status' => OrderPaymentStatus::Pending,
                'delivery_address_text' => $deliveryAddressText,
                'issue_description' => $issueDescription,
                'workflow_state' => OrderWorkflowState::None,
            ]);

            $this->appendHistory($order, OrderStatus::Placed, $buyer->id);

            if ($order->workflow_id) {
                $firstStep = WorkflowStep::query()
                    ->where('workflow_id', $order->workflow_id)
                    ->orderBy('sequence')
                    ->first();

                if ($firstStep && $firstStep->step_key === 'request_submitted') {
                    $order->forceFill([
                        'workflow_step_id' => $firstStep->id,
                        'workflow_state' => OrderWorkflowState::InProgress,
                        'workflow_started_at' => now(),
                    ])->save();

                    OrderWorkflowEvent::create([
                        'order_id' => $order->id,
                        'from_step_id' => null,
                        'to_step_id' => $firstStep->id,
                        'changed_by_user_id' => $buyer->id,
                        'created_at' => now(),
                    ]);
                }
            }

            return $order->fresh(['shop', 'zone', 'workflow', 'workflowStep', 'workflowEvents.toStep', 'workflowEvents.fromStep']);
        });
    }

    public function confirmDelivery(User $buyer, Order $order): Order
    {
        if ((int) $order->buyer_user_id !== (int) $buyer->id) {
            throw new \RuntimeException('Forbidden.');
        }

        return DB::transaction(function () use ($buyer, $order): Order {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === OrderStatus::Confirmed) {
                return $locked->fresh(['escrowHold', 'dispatchJob']);
            }

            if ($locked->status !== OrderStatus::Delivered) {
                throw new \RuntimeException('Order is not delivered.');
            }

            $locked->forceFill(['status' => OrderStatus::Confirmed])->save();
            $this->appendHistory($locked, OrderStatus::Confirmed, $buyer->id);

            $hold = $locked->escrowHold()->firstOrFail();
            $this->escrowService->release($hold, $buyer->id);

            return $locked->fresh(['escrowHold', 'dispatchJob']);
        });
    }

    /**
     * @param  array{reason:string, description?:string|null}  $payload
     */
    public function raiseDispute(User $buyer, Order $order, array $payload): Dispute
    {
        if ((int) $order->buyer_user_id !== (int) $buyer->id) {
            throw new \RuntimeException('Forbidden.');
        }

        return DB::transaction(function () use ($buyer, $order, $payload): Dispute {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            $existing = Dispute::query()->where('order_id', $locked->id)->first();
            if ($existing) {
                return $existing;
            }

            if ($locked->status !== OrderStatus::Delivered) {
                throw new \RuntimeException('Disputes can only be raised after delivery.');
            }

            $hold = $locked->escrowHold()->lockForUpdate()->firstOrFail();
            if ($hold->hold_expires_at && now()->greaterThan($hold->hold_expires_at)) {
                throw new \RuntimeException('Dispute window has expired.');
            }

            $dispute = Dispute::create([
                'order_id' => $locked->id,
                'raised_by_user_id' => $buyer->id,
                'reason' => $payload['reason'],
                'description' => $payload['description'] ?? null,
                'status' => DisputeStatus::Open,
            ]);

            $locked->forceFill(['status' => OrderStatus::Disputed])->save();
            $this->appendHistory($locked, OrderStatus::Disputed, $buyer->id);

            $this->escrowService->freeze($hold);

            return $dispute;
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
