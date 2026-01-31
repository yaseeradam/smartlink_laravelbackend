<?php

namespace App\Domain\Shipping\Services;

use App\Domain\Escrow\Jobs\AutoReleaseEscrowJob;
use App\Domain\Orders\Enums\OrderFulfillmentMode;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Shipping\Enums\ShipmentShippingType;
use App\Domain\Shipping\Enums\ShipmentStatus;
use App\Domain\Shipping\Events\ShipmentUpdated;
use App\Domain\Shipping\Models\Shipment;
use App\Domain\Shipping\Models\ShipmentStatusHistory;
use App\Domain\Users\Models\User;
use App\Domain\Escrow\Services\EscrowService;
use Illuminate\Support\Facades\DB;

class ShippingService
{
    public function __construct(private readonly EscrowService $escrowService)
    {
    }

    /**
     * @param  array{
     *   shipping_type?: string|null,
     *   courier_name?: string|null,
     *   shipping_fee?: float|int|string|null,
     *   eta_days_min?: int|null,
     *   eta_days_max?: int|null
     * }  $payload
     */
    public function createShipment(User $seller, Order $order, array $payload): Shipment
    {
        return DB::transaction(function () use ($seller, $order, $payload): Shipment {
            /** @var Order $locked */
            $locked = Order::query()->with(['shop', 'shipment'])->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ($locked->fulfillment_mode !== OrderFulfillmentMode::Shipping) {
                throw new \RuntimeException('Order is not a shipping order.');
            }

            if ($locked->admin_paused_at) {
                throw new \RuntimeException('Order is paused.');
            }

            if ((int) ($locked->shop?->seller_user_id ?? 0) !== (int) $seller->id) {
                throw new \RuntimeException('Forbidden.');
            }

            if ($locked->shipment) {
                return $locked->shipment->fresh(['timeline']);
            }

            $originState = (string) (DB::table('zones')->where('id', (int) ($locked->shop?->zone_id ?? 0))->value('state') ?? '');
            $destinationState = (string) (DB::table('zones')->where('id', (int) $locked->zone_id)->value('state') ?? '');

            $shippingType = ShipmentShippingType::tryFrom((string) ($payload['shipping_type'] ?? 'seller_handled'))
                ?? ShipmentShippingType::SellerHandled;

            $shipment = Shipment::create([
                'order_id' => $locked->id,
                'shipping_type' => $shippingType,
                'courier_name' => $payload['courier_name'] ?? null,
                'tracking_number' => null,
                'origin_state' => $originState !== '' ? $originState : null,
                'destination_state' => $destinationState !== '' ? $destinationState : null,
                'shipping_fee' => (float) ($payload['shipping_fee'] ?? 0),
                'status' => ShipmentStatus::Pending,
                'proof_dropoff_url' => null,
                'proof_delivery_url' => null,
                'eta_days_min' => $payload['eta_days_min'] ?? null,
                'eta_days_max' => $payload['eta_days_max'] ?? null,
            ]);

            $this->appendTimeline($shipment, ShipmentStatus::Pending, $seller->id, meta: [
                'courier_name' => $shipment->courier_name,
                'eta_days_min' => $shipment->eta_days_min,
                'eta_days_max' => $shipment->eta_days_max,
            ]);

            event(new ShipmentUpdated($locked->id, $shipment));

            return $shipment->fresh(['timeline']);
        });
    }

    public function markPacked(User $seller, Order $order): Shipment
    {
        return $this->updateShipmentStatus($seller, $order, ShipmentStatus::Packed);
    }

    /**
     * @param  array{tracking_number:string, proof_dropoff_url:string}  $payload
     */
    public function markDroppedOff(User $seller, Order $order, array $payload): Shipment
    {
        return DB::transaction(function () use ($seller, $order, $payload): Shipment {
            $shipment = $this->getShipmentForSeller($seller, $order, lock: true);

            $tracking = trim((string) ($payload['tracking_number'] ?? ''));
            $proof = trim((string) ($payload['proof_dropoff_url'] ?? ''));
            if ($tracking === '' || $proof === '') {
                throw new \InvalidArgumentException('tracking_number and proof_dropoff_url are required.');
            }

            $shipment->forceFill([
                'tracking_number' => $tracking,
                'proof_dropoff_url' => $proof,
            ])->save();

            $shipment = $this->transitionStatus($shipment, ShipmentStatus::DroppedOff, $seller->id, meta: [
                'tracking_number' => $tracking,
                'proof_dropoff_url' => $proof,
            ]);

            event(new ShipmentUpdated($order->id, $shipment));

            return $shipment->fresh(['timeline']);
        });
    }

    /**
     * @param  array{status:string, proof_delivery_url?:string|null}  $payload
     */
    public function updateStatus(User $seller, Order $order, array $payload): Shipment
    {
        $status = ShipmentStatus::tryFrom((string) ($payload['status'] ?? ''));
        if (! $status) {
            throw new \InvalidArgumentException('Invalid status.');
        }

        return DB::transaction(function () use ($seller, $order, $payload, $status): Shipment {
            $shipment = $this->getShipmentForSeller($seller, $order, lock: true);

            if ($status === ShipmentStatus::DroppedOff) {
                throw new \InvalidArgumentException('Use mark-dropped-off for dropped_off.');
            }

            if ($status === ShipmentStatus::Delivered) {
                $proofDelivery = trim((string) ($payload['proof_delivery_url'] ?? ''));
                if ($proofDelivery !== '') {
                    $shipment->forceFill(['proof_delivery_url' => $proofDelivery])->save();
                }
            }

            $shipment = $this->transitionStatus($shipment, $status, $seller->id, meta: [
                'proof_delivery_url' => $shipment->proof_delivery_url,
            ]);

            if ($status === ShipmentStatus::Delivered) {
                $this->markOrderDeliveredForShipping($order, $seller->id);
                $this->scheduleShippingAutoReleaseIfNeeded($order);
            }

            event(new ShipmentUpdated($order->id, $shipment));

            return $shipment->fresh(['timeline']);
        });
    }

    public function confirmDelivery(User $buyer, Order $order): Order
    {
        if ((int) $order->buyer_user_id !== (int) $buyer->id) {
            throw new \RuntimeException('Forbidden.');
        }

        return DB::transaction(function () use ($buyer, $order): Order {
            /** @var Order $locked */
            $locked = Order::query()
                ->with(['shipment', 'escrowHold', 'shipment.timeline'])
                ->whereKey($order->id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($locked->fulfillment_mode !== OrderFulfillmentMode::Shipping) {
                throw new \RuntimeException('Order is not a shipping order.');
            }

            if ($locked->admin_paused_at) {
                throw new \RuntimeException('Order is paused.');
            }

            if ($locked->status === OrderStatus::Confirmed) {
                return $locked->fresh(['escrowHold', 'shipment.timeline']);
            }

            if ($locked->status !== OrderStatus::Delivered) {
                throw new \RuntimeException('Order is not delivered.');
            }

            /** @var Shipment|null $shipment */
            $shipment = $locked->shipment;
            if (! $shipment || $shipment->status !== ShipmentStatus::Delivered) {
                throw new \RuntimeException('Shipment is not delivered.');
            }

            $shipment->forceFill(['status' => ShipmentStatus::Confirmed])->save();
            $this->appendTimeline($shipment, ShipmentStatus::Confirmed, $buyer->id, meta: null);

            $locked->forceFill(['status' => OrderStatus::Confirmed])->save();
            OrderStatusHistory::create([
                'order_id' => $locked->id,
                'status' => OrderStatus::Confirmed->value,
                'changed_by_user_id' => $buyer->id,
            ]);

            $hold = $locked->escrowHold()->firstOrFail();
            $this->escrowService->release($hold, $buyer->id);

            event(new ShipmentUpdated($locked->id, $shipment));

            return $locked->fresh(['escrowHold', 'shipment.timeline']);
        });
    }

    private function updateShipmentStatus(User $seller, Order $order, ShipmentStatus $status): Shipment
    {
        return DB::transaction(function () use ($seller, $order, $status): Shipment {
            $shipment = $this->getShipmentForSeller($seller, $order, lock: true);

            if ($status === ShipmentStatus::DroppedOff) {
                throw new \InvalidArgumentException('Use mark-dropped-off for dropped_off.');
            }

            $shipment = $this->transitionStatus($shipment, $status, $seller->id, meta: null);

            event(new ShipmentUpdated($order->id, $shipment));

            return $shipment->fresh(['timeline']);
        });
    }

    private function getShipmentForSeller(User $seller, Order $order, bool $lock): Shipment
    {
        $query = Order::query()->with(['shop', 'shipment'])->whereKey($order->id);
        if ($lock) {
            $query->lockForUpdate();
        }

        /** @var Order $locked */
        $locked = $query->firstOrFail();

        if ($locked->fulfillment_mode !== OrderFulfillmentMode::Shipping) {
            throw new \RuntimeException('Order is not a shipping order.');
        }

        if ($locked->admin_paused_at) {
            throw new \RuntimeException('Order is paused.');
        }

        if ((int) ($locked->shop?->seller_user_id ?? 0) !== (int) $seller->id) {
            throw new \RuntimeException('Forbidden.');
        }

        /** @var Shipment|null $shipment */
        $shipment = $locked->shipment;
        if (! $shipment) {
            throw new \RuntimeException('Shipment not created yet.');
        }

        return $shipment;
    }

    /**
     * @param  array<string,mixed>|null  $meta
     */
    private function appendTimeline(Shipment $shipment, ShipmentStatus $status, ?int $actorUserId, ?array $meta): void
    {
        ShipmentStatusHistory::create([
            'shipment_id' => $shipment->id,
            'status' => $status->value,
            'changed_by_user_id' => $actorUserId,
            'meta_json' => $meta,
        ]);
    }

    /**
     * @param  array<string,mixed>|null  $meta
     */
    private function transitionStatus(Shipment $shipment, ShipmentStatus $to, ?int $actorUserId, ?array $meta): Shipment
    {
        if ($shipment->status === $to) {
            return $shipment;
        }

        if ($shipment->status === ShipmentStatus::Confirmed) {
            throw new \RuntimeException('Shipment is already confirmed.');
        }

        $shipment->forceFill(['status' => $to])->save();
        $this->appendTimeline($shipment, $to, $actorUserId, $meta);

        return $shipment->fresh(['timeline']);
    }

    private function markOrderDeliveredForShipping(Order $order, int $actorUserId): void
    {
        /** @var Order $locked */
        $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

        if ($locked->status === OrderStatus::Delivered || $locked->status === OrderStatus::Confirmed) {
            return;
        }

        $locked->forceFill(['status' => OrderStatus::Delivered])->save();
        OrderStatusHistory::create([
            'order_id' => $locked->id,
            'status' => OrderStatus::Delivered->value,
            'changed_by_user_id' => $actorUserId,
        ]);
    }

    private function scheduleShippingAutoReleaseIfNeeded(Order $order): void
    {
        /** @var Order $locked */
        $locked = Order::query()->with(['escrowHold'])->whereKey($order->id)->lockForUpdate()->firstOrFail();

        $hold = $locked->escrowHold;
        if (! $hold) {
            return;
        }

        if ($hold->hold_expires_at) {
            return;
        }

        $hours = (int) config('smartlink.shipping.auto_release_hours', 72);
        $hours = max(1, $hours);

        $expiresAt = now()->addHours($hours);
        $hold->forceFill(['hold_expires_at' => $expiresAt])->save();

        dispatch((new AutoReleaseEscrowJob($hold->id))->delay($expiresAt)->afterCommit());
    }
}
