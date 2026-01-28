<?php

namespace Tests\Feature;

use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Dispatch\Models\DispatchOffer;
use App\Domain\Orders\Models\Order;
use App\Domain\Products\Models\Product;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DispatchAcceptTest extends TestCase
{
    use RefreshDatabase;

    public function test_first_rider_accept_wins_and_expires_others(): void
    {
        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
        ]);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08044444444',
            'email' => 'seller2@test.local',
            'password' => 'password',
            'role' => UserRole::Seller,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $seller->id, 'zone_id' => $zone->id, 'type' => 'operational']);

        $shop = Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
        ]);

        $buyer = User::create([
            'full_name' => 'Buyer',
            'phone' => '08055555555',
            'email' => 'buyer3@test.local',
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
            'status' => 'dispatching',
            'payment_status' => 'paid',
            'delivery_address_text' => 'Addr',
        ]);

        $rider1 = User::create([
            'full_name' => 'Rider 1',
            'phone' => '08066666666',
            'email' => 'rider1@test.local',
            'password' => 'password',
            'role' => UserRole::Rider,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        $rider2 = User::create([
            'full_name' => 'Rider 2',
            'phone' => '08077777777',
            'email' => 'rider2@test.local',
            'password' => 'password',
            'role' => UserRole::Rider,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $rider1->id, 'zone_id' => $zone->id, 'type' => 'operational']);
        UserZone::create(['user_id' => $rider2->id, 'zone_id' => $zone->id, 'type' => 'operational']);

        \App\Domain\Riders\Models\RiderAvailability::create(['rider_user_id' => $rider1->id, 'status' => 'available', 'last_seen_at' => now()]);
        \App\Domain\Riders\Models\RiderAvailability::create(['rider_user_id' => $rider2->id, 'status' => 'available', 'last_seen_at' => now()]);

        $job = DispatchJob::create([
            'order_id' => $order->id,
            'shop_id' => $shop->id,
            'zone_id' => $zone->id,
            'status' => 'broadcasting',
            'assigned_rider_user_id' => null,
            'private_pool_only_until' => now()->addMinutes(10),
            'fallback_broadcast_at' => now()->addMinutes(10),
        ]);

        $offer1 = DispatchOffer::create([
            'dispatch_job_id' => $job->id,
            'rider_user_id' => $rider1->id,
            'offer_status' => 'sent',
            'offered_at' => now(),
        ]);

        $offer2 = DispatchOffer::create([
            'dispatch_job_id' => $job->id,
            'rider_user_id' => $rider2->id,
            'offer_status' => 'sent',
            'offered_at' => now(),
        ]);

        Sanctum::actingAs($rider1);
        $resp1 = $this->postJson("/api/rider/dispatch/offers/{$offer1->id}/accept");
        $resp1->assertOk();

        $job->refresh();
        $this->assertSame($rider1->id, $job->assigned_rider_user_id);

        Sanctum::actingAs($rider2);
        $resp2 = $this->postJson("/api/rider/dispatch/offers/{$offer2->id}/accept");
        $resp2->assertStatus(409);

        $offer2->refresh();
        $this->assertSame('expired', $offer2->offer_status->value);
    }
}

