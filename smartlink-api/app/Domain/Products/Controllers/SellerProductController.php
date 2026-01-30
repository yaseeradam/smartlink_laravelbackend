<?php

namespace App\Domain\Products\Controllers;

use App\Domain\Products\Models\Product;
use App\Domain\Products\Models\ProductImage;
use App\Domain\Products\Requests\CreateProductRequest;
use App\Domain\Products\Requests\UpdateProductRequest;
use App\Domain\Products\Resources\ProductResource;
use App\Domain\Shops\Models\Shop;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class SellerProductController
{
    public function store(CreateProductRequest $request)
    {
        $seller = $request->user();
        $data = $request->validated();

        /** @var Shop|null $shop */
        $shopId = isset($data['shop_id']) ? (int) $data['shop_id'] : null;
        $shop = Shop::query()
            ->when($shopId, fn ($q) => $q->whereKey($shopId))
            ->where('seller_user_id', $seller->id)
            ->orderByDesc('id')
            ->first();
        if (! $shop) {
            return response()->json(['message' => 'Create a shop first.'], 422);
        }

        $disk = (string) config('smartlink.media_disk', 'local');

        $product = DB::transaction(function () use ($shop, $data, $request, $disk) {
            $product = Product::create([
                'shop_id' => $shop->id,
                'name' => $data['name'],
                'description' => $data['description'] ?? null,
                'price' => $data['price'],
                'currency' => (string) config('smartlink.currency', 'NGN'),
                'stock_qty' => $data['stock_qty'],
                'status' => $data['status'] ?? 'active',
            ]);

            $files = $request->file('images', []);
            foreach ($files as $i => $file) {
                $path = Storage::disk($disk)->putFileAs(
                    "products/{$product->id}",
                    $file,
                    Str::uuid()->toString().'.'.$file->getClientOriginalExtension(),
                );

                ProductImage::create([
                    'product_id' => $product->id,
                    'image_url' => Storage::disk($disk)->url($path),
                    'sort_order' => $i,
                ]);
            }

            return $product;
        });

        return new ProductResource($product->load('images'));
    }

    public function update(UpdateProductRequest $request, Product $product)
    {
        Gate::authorize('update', $product);

        $data = $request->validated();
        $disk = (string) config('smartlink.media_disk', 'local');

        DB::transaction(function () use ($product, $data, $request, $disk) {
            $product->fill(collect($data)->except(['images'])->all());
            $product->save();

            if ($request->hasFile('images')) {
                $product->images()->delete();

                $files = $request->file('images', []);
                foreach ($files as $i => $file) {
                    $path = Storage::disk($disk)->putFileAs(
                        "products/{$product->id}",
                        $file,
                        Str::uuid()->toString().'.'.$file->getClientOriginalExtension(),
                    );

                    ProductImage::create([
                        'product_id' => $product->id,
                        'image_url' => Storage::disk($disk)->url($path),
                        'sort_order' => $i,
                    ]);
                }
            }
        });

        return new ProductResource($product->fresh()->load('images'));
    }
}
