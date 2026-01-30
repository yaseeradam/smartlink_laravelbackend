<?php

namespace App\Domain\Dispatch\Controllers;

use App\Domain\Dispatch\Models\SellerRiderPool;
use App\Domain\Dispatch\Requests\ManageRiderPoolRequest;
use App\Domain\Dispatch\Services\DispatchService;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Shops\Models\Shop;
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
        $requestedShopId = request()->query('shop_id');
        $shopId = $requestedShopId ? (int) $requestedShopId : null;

        if ($shopId) {
            $ownsShop = Shop::query()
                ->whereKey($shopId)
                ->where('seller_user_id', $seller->id)
                ->exists();
            if (! $ownsShop) {
                return response()->json(['message' => 'Forbidden.'], 403);
            }
        }

        $shopIds = $shopId
            ? [$shopId]
            : Shop::query()->where('seller_user_id', $seller->id)->pluck('id')->all();

        $orders = Order::query()
            ->whereIn('shop_id', $shopIds !== [] ? $shopIds : [0])
            ->latest('id')
            ->paginate(20);

        return OrderResource::collection($orders);
    }

    public function addRiderToPool(ManageRiderPoolRequest $request)
    {
        $seller = $request->user();
        $data = $request->validated();

        $shopId = isset($data['shop_id']) ? (int) $data['shop_id'] : (int) ($seller->shop?->id ?? 0);
        if (! $shopId) {
            return response()->json(['message' => 'Create a shop first.'], 422);
        }

        $ownsShop = Shop::query()
            ->whereKey($shopId)
            ->where('seller_user_id', $seller->id)
            ->exists();
        if (! $ownsShop) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

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
        $data = $request->validated();

        $shopId = isset($data['shop_id']) ? (int) $data['shop_id'] : (int) ($seller->shop?->id ?? 0);
        if (! $shopId) {
            return response()->json(['message' => 'Create a shop first.'], 422);
        }

        $ownsShop = Shop::query()
            ->whereKey($shopId)
            ->where('seller_user_id', $seller->id)
            ->exists();
        if (! $ownsShop) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

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

        if ($order->workflow_id) {
            $order->loadMissing('workflowStep');
            if (! $order->workflowStep || ! $order->workflowStep->is_dispatch_trigger) {
                return response()->json(['message' => 'Dispatch is blocked until the order is ready.'], 409);
            }
        }

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
