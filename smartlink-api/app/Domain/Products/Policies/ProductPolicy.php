<?php

namespace App\Domain\Products\Policies;

use App\Domain\Products\Models\Product;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Models\User;

class ProductPolicy
{
    public function update(User $user, Product $product): bool
    {
        return $user->role === UserRole::Seller
            && $user->shops()->whereKey((int) $product->shop_id)->exists();
    }
}
