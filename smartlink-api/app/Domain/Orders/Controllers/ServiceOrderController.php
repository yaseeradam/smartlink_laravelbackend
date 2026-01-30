<?php

namespace App\Domain\Orders\Controllers;

use App\Domain\Orders\Requests\StoreServiceOrderRequest;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Orders\Services\OrderService;

class ServiceOrderController
{
    public function __construct(private readonly OrderService $orderService)
    {
    }

    public function store(StoreServiceOrderRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        try {
            $order = $this->orderService->placeServiceOrder(
                $user,
                (int) $data['shop_id'],
                (string) $data['delivery_address_text'],
                (string) $data['service_type'],
                $data['issue_description'] ?? null,
            );
        } catch (\RuntimeException | \InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new OrderResource($order->load([
            'items',
            'escrowHold',
            'workflow',
            'workflowStep',
            'workflowEvents.toStep',
            'workflowEvents.fromStep',
        ]));
    }
}

