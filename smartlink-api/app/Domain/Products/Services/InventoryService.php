<?php

namespace App\Domain\Products\Services;

use App\Domain\Orders\Models\Order;
use App\Domain\Products\Enums\ProductStatus;
use App\Domain\Products\Models\Product;
use Illuminate\Support\Facades\DB;

class InventoryService
{
    public function restoreOrderStock(Order $order): void
    {
        DB::transaction(function () use ($order) {
            $items = $order->items()->get();

            foreach ($items as $item) {
                /** @var Product $product */
                $product = Product::query()->whereKey($item->product_id)->lockForUpdate()->first();
                if (! $product) {
                    continue;
                }

                $product->forceFill(['stock_qty' => $product->stock_qty + (int) $item->qty])->save();

                if ($product->status === ProductStatus::OutOfStock && $product->stock_qty > 0) {
                    $product->forceFill(['status' => ProductStatus::Active])->save();
                }
            }
        });
    }
}
