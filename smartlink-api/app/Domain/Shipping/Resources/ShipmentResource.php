<?php

namespace App\Domain\Shipping\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ShipmentResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Shipping\Models\Shipment $shipment */
        $shipment = $this->resource;

        return [
            'id' => $shipment->id,
            'order_id' => $shipment->order_id,
            'shipping_type' => $shipment->shipping_type->value,
            'courier_name' => $shipment->courier_name,
            'tracking_number' => $shipment->tracking_number,
            'origin_state' => $shipment->origin_state,
            'destination_state' => $shipment->destination_state,
            'shipping_fee' => (string) $shipment->shipping_fee,
            'status' => $shipment->status->value,
            'proof_dropoff_url' => $shipment->proof_dropoff_url,
            'proof_delivery_url' => $shipment->proof_delivery_url,
            'eta_days_min' => $shipment->eta_days_min,
            'eta_days_max' => $shipment->eta_days_max,
            'timeline' => $this->whenLoaded('timeline', function () use ($shipment) {
                return $shipment->timeline->map(function ($e) {
                    return [
                        'status' => $e->status,
                        'changed_by_user_id' => $e->changed_by_user_id,
                        'meta' => $e->meta_json,
                        'created_at' => optional($e->created_at)?->toISOString(),
                    ];
                })->values();
            }),
            'created_at' => optional($shipment->created_at)?->toISOString(),
            'updated_at' => optional($shipment->updated_at)?->toISOString(),
        ];
    }
}

