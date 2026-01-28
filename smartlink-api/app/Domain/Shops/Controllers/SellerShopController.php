<?php

namespace App\Domain\Shops\Controllers;

use App\Domain\Shops\Models\Shop;
use App\Domain\Shops\Requests\CreateShopRequest;
use App\Domain\Shops\Resources\ShopResource;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Support\Facades\DB;

class SellerShopController
{
    public function store(CreateShopRequest $request)
    {
        $seller = $request->user();
        $data = $request->validated();

        $existing = Shop::query()->where('seller_user_id', $seller->id)->first();
        if ($existing) {
            return response()->json(['message' => 'Seller already has a shop.'], 409);
        }

        $operationalZoneId = UserZone::query()
            ->where('user_id', $seller->id)
            ->where('type', 'operational')
            ->value('zone_id');

        if (! $operationalZoneId) {
            return response()->json(['message' => 'Operational zone is required for sellers.'], 422);
        }

        if ((int) $operationalZoneId !== (int) $data['zone_id']) {
            return response()->json(['message' => 'Shop zone must match seller operational zone.'], 422);
        }

        $shop = DB::transaction(function () use ($seller, $data) {
            return Shop::create([
                'seller_user_id' => $seller->id,
                'shop_name' => $data['shop_name'],
                'description' => $data['description'] ?? null,
                'zone_id' => $data['zone_id'],
                'address_text' => $data['address_text'],
                'is_verified' => false,
                'verification_phase' => 'phase1',
            ]);
        });

        return new ShopResource($shop);
    }
}

