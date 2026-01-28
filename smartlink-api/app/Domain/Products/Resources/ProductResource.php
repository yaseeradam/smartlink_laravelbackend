<?php

namespace App\Domain\Products\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Products\Models\Product $product */
        $product = $this->resource;

        return [
            'id' => $product->id,
            'shop_id' => $product->shop_id,
            'name' => $product->name,
            'description' => $product->description,
            'price' => (string) $product->price,
            'currency' => $product->currency,
            'stock_qty' => $product->stock_qty,
            'status' => $product->status->value,
            'images' => $product->relationLoaded('images')
                ? $product->images->sortBy('sort_order')->pluck('image_url')->values()->all()
                : [],
            'created_at' => optional($product->created_at)?->toISOString(),
        ];
    }
}

