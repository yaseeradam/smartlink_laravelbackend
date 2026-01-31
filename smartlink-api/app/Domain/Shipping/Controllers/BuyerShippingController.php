<?php

namespace App\Domain\Shipping\Controllers;

use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Shipping\Services\ShippingService;
use Illuminate\Support\Facades\Gate;

class BuyerShippingController
{
    public function __construct(private readonly ShippingService $shippingService)
    {
    }

    public function confirmDelivery(Order $order)
    {
        Gate::authorize('confirmDelivery', $order);

        try {
            $updated = $this->shippingService->confirmDelivery(request()->user(), $order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new OrderResource($updated->loadMissing(['escrowHold', 'shipment.timeline']));
    }
}

