<?php

namespace Tests\Feature;

use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Database\Seeders\WorkflowsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ServiceOrderEndpointTest extends TestCase
{
    use RefreshDatabase;

    public function test_service_order_endpoint_creates_service_order_without_escrow(): void
    {
        $this->seed(WorkflowsSeeder::class);

        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
            'status' => 'active',
        ]);

        $buyer = User::create([
            'full_name' => 'Buyer',
            'phone' => '08011111111',
            'email' => 'buyer@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);
        UserZone::create(['user_id' => $buyer->id, 'zone_id' => $zone->id, 'type' => 'home']);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08022222222',
            'email' => 'seller@test.local',
            'password' => 'password',
            'role' => UserRole::Seller,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);
        UserZone::create(['user_id' => $seller->id, 'zone_id' => $zone->id, 'type' => 'operational']);

        $shop = Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Repair Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
            'shop_type' => 'repair',
            'default_workflow_id' => null,
        ]);

        $shop->forceFill([
            'default_workflow_id' => \App\Domain\Workflows\Models\Workflow::query()->where('code', 'repair')->value('id'),
        ])->save();

        Sanctum::actingAs($buyer);

        $resp = $this->postJson('/api/orders/service', [
            'shop_id' => $shop->id,
            'delivery_address_text' => 'Addr',
            'service_type' => 'repair',
            'issue_description' => 'Broken screen',
        ])->assertOk();

        $orderId = (int) $resp->json('data.id');

        $this->assertDatabaseHas('orders', [
            'id' => $orderId,
            'order_kind' => 'service',
            'service_type' => 'repair',
            'payment_status' => 'pending',
        ]);

        $this->assertDatabaseMissing('escrow_holds', [
            'order_id' => $orderId,
        ]);
    }
}

