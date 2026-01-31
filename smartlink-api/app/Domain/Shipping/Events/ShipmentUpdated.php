<?php

namespace App\Domain\Shipping\Events;

use App\Domain\Shipping\Models\Shipment;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class ShipmentUpdated implements ShouldBroadcast
{
    use Dispatchable;
    use SerializesModels;

    public function __construct(public readonly int $orderId, public readonly Shipment $shipment)
    {
    }

    public function broadcastOn(): array
    {
        return [new PrivateChannel("private-order.{$this->orderId}")];
    }

    public function broadcastAs(): string
    {
        return 'ShipmentUpdated';
    }

    /**
     * @return array<string, mixed>
     */
    public function broadcastWith(): array
    {
        return [
            'order_id' => $this->orderId,
            'shipment' => [
                'id' => $this->shipment->id,
                'status' => $this->shipment->status->value,
                'shipping_type' => $this->shipment->shipping_type->value,
                'courier_name' => $this->shipment->courier_name,
                'tracking_number' => $this->shipment->tracking_number,
                'proof_dropoff_url' => $this->shipment->proof_dropoff_url,
                'proof_delivery_url' => $this->shipment->proof_delivery_url,
                'eta_days_min' => $this->shipment->eta_days_min,
                'eta_days_max' => $this->shipment->eta_days_max,
                'updated_at' => optional($this->shipment->updated_at)?->toISOString(),
            ],
        ];
    }
}

