<?php

namespace App\Domain\Orders\Controllers;

use App\Domain\Disputes\Resources\DisputeResource;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Requests\CancelOrderRequest;
use App\Domain\Orders\Requests\RaiseDisputeRequest;
use App\Domain\Orders\Requests\StoreOrderRequest;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Orders\Services\OrderService;
use App\Domain\Cancellations\Services\CancellationService;
use App\Domain\Notifications\Jobs\SendPushNotificationJob;
use App\Domain\Users\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class OrderController
{
    public function __construct(
        private readonly OrderService $orderService,
        private readonly CancellationService $cancellationService,
    ) {
    }

    public function store(StoreOrderRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        try {
            $order = $this->orderService->placeOrder(
                $user,
                (int) $data['shop_id'],
                (string) $data['delivery_address_text'],
                $data['items'],
            );
        } catch (\RuntimeException | \InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new OrderResource($order->load(['items', 'escrowHold']));
    }

    public function index(Request $request)
    {
        $user = $request->user();

        $orders = Order::query()
            ->when($user->role->value === 'buyer', fn ($q) => $q->where('buyer_user_id', $user->id))
            ->when($user->role->value === 'seller', function ($q) use ($user) {
                $shopId = $user->shop?->id;
                $q->where('shop_id', $shopId ?? 0);
            })
            ->when($user->role->value === 'rider', function ($q) use ($user) {
                $q->whereHas('dispatchJob', fn ($dq) => $dq->where('assigned_rider_user_id', $user->id));
            })
            ->latest('id')
            ->paginate(20);

        return OrderResource::collection($orders);
    }

    public function show(Request $request, Order $order)
    {
        Gate::authorize('view', $order);

        return new OrderResource($order->load(['items', 'escrowHold', 'dispatchJob']));
    }

    public function confirmDelivery(Request $request, Order $order)
    {
        Gate::authorize('confirmDelivery', $order);

        try {
            $updated = $this->orderService->confirmDelivery($request->user(), $order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new OrderResource($updated->load(['items', 'escrowHold']));
    }

    public function raiseDispute(RaiseDisputeRequest $request, Order $order)
    {
        Gate::authorize('raiseDispute', $order);

        try {
            $dispute = $this->orderService->raiseDispute($request->user(), $order, $request->validated());
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $sellerId = (int) ($order->shop?->seller_user_id ?? 0);
        if ($sellerId > 0) {
            dispatch(new SendPushNotificationJob(
                $sellerId,
                'Dispute raised',
                'A buyer has raised a dispute on an order.',
                ['order_id' => $order->id],
            ));
        }

        $admins = User::query()->where('role', 'admin')->get(['id']);
        foreach ($admins as $admin) {
            dispatch(new SendPushNotificationJob(
                (int) $admin->id,
                'Dispute raised',
                'A new dispute requires review.',
                ['order_id' => $order->id],
            ));
        }

        return new DisputeResource($dispute);
    }

    public function cancel(CancelOrderRequest $request, Order $order)
    {
        Gate::authorize('cancel', $order);

        try {
            $cancellation = $this->cancellationService->cancel(
                $request->user(),
                $order,
                (string) $request->validated()['reason'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'id' => $cancellation->id,
            'order_id' => $cancellation->order_id,
            'penalty_amount' => (string) $cancellation->penalty_amount,
            'created_at' => optional($cancellation->created_at)?->toISOString(),
        ]);
    }
}
