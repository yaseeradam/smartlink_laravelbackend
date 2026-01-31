<?php

namespace Tests\Feature;

use App\Domain\Dispatch\Services\DispatchService;
use App\Domain\Orders\Models\Order;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class DispatchShippingGuardTest extends TestCase
{
    use RefreshDatabase;

    public function test_dispatch_is_blocked_for_non_local_shipping_type(): void
    {
        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
            'status' => 'active',
        ]);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08088888888',
            'email' => 'seller-ship@test.local',
            'password' => 'password',
            'role' => UserRole::Seller,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $seller->id, 'zone_id' => $zone->id, 'type' => 'operational']);

        $shop = Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Ship Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
            'shipping_type' => 'state_shipping',
        ]);

        $buyer = User::create([
            'full_name' => 'Buyer',
            'phone' => '08099999999',
            'email' => 'buyer-ship@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $buyer->id, 'zone_id' => $zone->id, 'type' => 'home']);

        $order = Order::create([
            'buyer_user_id' => $buyer->id,
            'shop_id' => $shop->id,
            'zone_id' => $zone->id,
            'subtotal_amount' => 1000,
            'delivery_fee_amount' => 0,
            'total_amount' => 1000,
            'status' => 'paid',
            'payment_status' => 'paid',
            'delivery_address_text' => 'Addr',
        ]);

        $service = app(DispatchService::class);

        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('Shipping orders cannot use local rider dispatch.');

        $service->dispatchOrder($seller, $order);
    }
}

