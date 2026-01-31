<?php

namespace App\Domain\Shipping\Controllers;

use App\Domain\Orders\Models\Order;
use App\Domain\Shipping\Requests\CreateShipmentRequest;
use App\Domain\Shipping\Requests\MarkDroppedOffRequest;
use App\Domain\Shipping\Requests\UpdateShipmentStatusRequest;
use App\Domain\Shipping\Services\ShippingService;
use Illuminate\Support\Facades\Gate;

class SellerShippingController
{
    public function __construct(private readonly ShippingService $shippingService)
    {
    }

    public function create(CreateShipmentRequest $request, Order $order)
    {
        Gate::authorize('manageShipping', $order);

        try {
            $shipment = $this->shippingService->createShipment($request->user(), $order, $request->validated());
        } catch (\InvalidArgumentException | \RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json(['data' => $this->serializeShipment($shipment)], 201);
    }

    public function markPacked(Order $order)
    {
        $user = request()->user();
        Gate::authorize('manageShipping', $order);

        try {
            $shipment = $this->shippingService->markPacked($user, $order);
        } catch (\InvalidArgumentException | \RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json(['data' => $this->serializeShipment($shipment)]);
    }

    public function markDroppedOff(MarkDroppedOffRequest $request, Order $order)
    {
        Gate::authorize('manageShipping', $order);

        try {
            $shipment = $this->shippingService->markDroppedOff($request->user(), $order, $request->validated());
        } catch (\InvalidArgumentException | \RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json(['data' => $this->serializeShipment($shipment)]);
    }

    public function updateStatus(UpdateShipmentStatusRequest $request, Order $order)
    {
        Gate::authorize('manageShipping', $order);

        try {
            $shipment = $this->shippingService->updateStatus($request->user(), $order, $request->validated());
        } catch (\InvalidArgumentException | \RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json(['data' => $this->serializeShipment($shipment)]);
    }

    /**
     * @return array<string,mixed>
     */
    private function serializeShipment($shipment): array
    {
        $timeline = $shipment->relationLoaded('timeline') ? $shipment->timeline : [];

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
            'timeline' => collect($timeline)->map(function ($e) {
                return [
                    'status' => $e->status,
                    'changed_by_user_id' => $e->changed_by_user_id,
                    'meta' => $e->meta_json,
                    'created_at' => optional($e->created_at)?->toISOString(),
                ];
            })->values(),
            'created_at' => optional($shipment->created_at)?->toISOString(),
            'updated_at' => optional($shipment->updated_at)?->toISOString(),
        ];
    }
}

