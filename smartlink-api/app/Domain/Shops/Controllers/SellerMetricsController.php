<?php

namespace App\Domain\Shops\Controllers;

use App\Domain\Shops\Services\SellerMetricsService;

class SellerMetricsController
{
    public function __construct(private readonly SellerMetricsService $metricsService)
    {
    }

    public function show()
    {
        $seller = request()->user();
        $requestedShopId = request()->query('shop_id');
        $shopId = $requestedShopId ? (int) $requestedShopId : (int) ($seller->shop?->id ?? 0);

        if (! $shopId) {
            return response()->json(['message' => 'Shop not found.'], 404);
        }

        $ownsShop = \App\Domain\Shops\Models\Shop::query()
            ->whereKey($shopId)
            ->where('seller_user_id', $seller->id)
            ->exists();
        if (! $ownsShop) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        return response()->json($this->metricsService->forSellerShop((int) $shopId));
    }
}
