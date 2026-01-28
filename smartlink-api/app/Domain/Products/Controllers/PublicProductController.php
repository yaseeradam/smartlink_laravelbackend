<?php

namespace App\Domain\Products\Controllers;

use App\Domain\Products\Models\Product;
use App\Domain\Products\Resources\ProductResource;
use Illuminate\Http\Request;

class PublicProductController
{
    public function index(Request $request)
    {
        $zoneId = $request->query('zone_id');
        $shopId = $request->query('shop_id');

        $products = Product::query()
            ->with('images')
            ->where('status', 'active')
            ->whereHas('shop', function ($q) use ($zoneId, $shopId) {
                $q->where('is_verified', true)
                    ->whereHas('zone', fn ($z) => $z->where('is_active', true)->where('status', 'active'))
                    ->when($zoneId, fn ($qq) => $qq->where('zone_id', $zoneId))
                    ->when($shopId, fn ($qq) => $qq->where('id', $shopId));
            })
            ->latest('id')
            ->paginate(20);

        return ProductResource::collection($products);
    }

    public function show(Product $product)
    {
        if (! $product->shop()->where('is_verified', true)->whereHas('zone', fn ($z) => $z->where('is_active', true)->where('status', 'active'))->exists()) {
            return response()->json(['message' => 'Not found.'], 404);
        }

        return new ProductResource($product->load('images'));
    }
}
