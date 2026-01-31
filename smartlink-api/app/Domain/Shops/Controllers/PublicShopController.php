<?php

namespace App\Domain\Shops\Controllers;

use App\Domain\Shops\Models\Shop;
use App\Domain\Shops\Resources\ShopResource;
use Illuminate\Http\Request;

class PublicShopController
{
    public function index(Request $request)
    {
        $zoneId = $request->query('zone_id');

        $shops = Shop::query()
            ->where('status', 'active')
            ->where('is_verified', true)
            ->whereHas('zone', fn ($q) => $q->where('is_active', true)->where('status', 'active'))
            ->when($zoneId, fn ($q) => $q->where('zone_id', $zoneId))
            ->latest('id')
            ->paginate(20);

        return ShopResource::collection($shops);
    }

    public function show(Shop $shop)
    {
        if ($shop->status !== 'active' || ! $shop->is_verified || ! $shop->zone?->is_active || $shop->zone?->status?->value === 'paused') {
            return response()->json(['message' => 'Not found.'], 404);
        }

        return new ShopResource($shop);
    }
}
