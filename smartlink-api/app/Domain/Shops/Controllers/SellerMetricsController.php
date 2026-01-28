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
        $shopId = $seller->shop?->id;

        if (! $shopId) {
            return response()->json(['message' => 'Shop not found.'], 404);
        }

        return response()->json($this->metricsService->forSellerShop((int) $shopId));
    }
}
