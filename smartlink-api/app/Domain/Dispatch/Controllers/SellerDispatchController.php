<?php

namespace App\Domain\Dispatch\Controllers;

use App\Domain\Dispatch\Models\SellerRiderPool;
use App\Domain\Dispatch\Requests\ManageRiderPoolRequest;
use App\Domain\Dispatch\Services\DispatchService;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Users\Models\User;
use Illuminate\Support\Facades\Gate;

class SellerDispatchController
{
    public function __construct(private readonly DispatchService $dispatchService)
    {
    }

    public function orders()
    {
        $seller = request()->user();
        $shopId = $seller->shop?->id;

        $orders = Order::query()
            ->where('shop_id', $shopId ?? 0)
            ->latest('id')
            ->paginate(20);

        return OrderResource::collection($orders);
    }

    public function addRiderToPool(ManageRiderPoolRequest $request)
    {
        $seller = $request->user();
        $shopId = $seller->shop?->id;
        if (! $shopId) {
            return response()->json(['message' => 'Create a shop first.'], 422);
        }
        $data = $request->validated();

        /** @var User $rider */
        $rider = User::query()->whereKey($data['rider_user_id'])->firstOrFail();
        if ($rider->role->value !== 'rider' || $rider->status->value !== 'active') {
            return response()->json(['message' => 'Rider must be active.'], 422);
        }

        if (! RiderAvailability::query()->where('rider_user_id', $rider->id)->exists()) {
            return response()->json(['message' => 'Rider profile not found.'], 422);
        }

        $record = SellerRiderPool::updateOrCreate(
            ['shop_id' => $shopId, 'rider_user_id' => $rider->id],
            ['status' => 'active', 'added_by' => $seller->id],
        );

        return response()->json(['message' => 'Rider added.', 'id' => $record->id]);
    }

    public function removeRiderFromPool(ManageRiderPoolRequest $request)
    {
        $seller = $request->user();
        $shopId = $seller->shop?->id;
        if (! $shopId) {
            return response()->json(['message' => 'Create a shop first.'], 422);
        }
        $data = $request->validated();

        SellerRiderPool::query()
            ->where('shop_id', $shopId)
            ->where('rider_user_id', $data['rider_user_id'])
            ->update(['status' => 'removed', 'added_by' => $seller->id]);

        return response()->json(['message' => 'Rider removed.']);
    }

    public function dispatch(Order $order)
    {
        $seller = request()->user();
        Gate::authorize('dispatch', $order);

        try {
            $job = $this->dispatchService->dispatchOrder($seller, $order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'dispatch_job_id' => $job->id,
            'status' => $job->status->value,
            'private_pool_only_until' => optional($job->private_pool_only_until)?->toISOString(),
            'fallback_broadcast_at' => optional($job->fallback_broadcast_at)?->toISOString(),
        ]);
    }
}
