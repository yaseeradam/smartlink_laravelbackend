<?php

namespace App\Domain\Shops\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ShopResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Shops\Models\Shop $shop */
        $shop = $this->resource;

        return [
            'id' => $shop->id,
            'seller_user_id' => $shop->seller_user_id,
            'shop_name' => $shop->shop_name,
            'description' => $shop->description,
            'zone_id' => $shop->zone_id,
            'address_text' => $shop->address_text,
            'is_verified' => (bool) $shop->is_verified,
            'verification_phase' => $shop->verification_phase->value,
            'created_at' => optional($shop->created_at)?->toISOString(),
        ];
    }
}

