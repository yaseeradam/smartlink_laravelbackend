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

class SellerMultiShopAndWorkflowAdminTest extends TestCase
{
    use RefreshDatabase;

    public function test_seller_can_create_multiple_shops_and_list_them(): void
    {
        $this->seed(WorkflowsSeeder::class);

        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
            'status' => 'active',
        ]);

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

        Sanctum::actingAs($seller);

        $this->postJson('/api/seller/shop', [
            'shop_name' => 'Shop 1',
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'shop_type' => 'food',
        ])->assertStatus(201);

        $this->postJson('/api/seller/shop', [
            'shop_name' => 'Shop 2',
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'shop_type' => 'repair',
        ])->assertStatus(201);

        $resp = $this->getJson('/api/seller/shops')->assertOk();
        $this->assertCount(2, $resp->json('data'));
    }

    public function test_admin_can_create_workflow_and_seller_can_set_shop_default_workflow(): void
    {
        $this->seed(WorkflowsSeeder::class);

        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
            'status' => 'active',
        ]);

        $admin = User::create([
            'full_name' => 'Admin',
            'phone' => '08099999999',
            'email' => 'admin@test.local',
            'password' => 'password',
            'role' => UserRole::Admin,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        Sanctum::actingAs($admin);

        $workflowId = (int) $this->postJson('/api/admin/workflows', [
            'code' => 'custom_service',
            'name' => 'Custom Service Flow',
            'is_active' => true,
        ])->assertStatus(201)->json('data.id');

        $this->postJson("/api/admin/workflows/{$workflowId}/steps", [
            'step_key' => 'accepted',
            'title' => 'Accepted',
            'sequence' => 1,
        ])->assertStatus(201);

        $this->postJson("/api/admin/workflows/{$workflowId}/steps", [
            'step_key' => 'ready',
            'title' => 'Ready',
            'sequence' => 2,
            'is_dispatch_trigger' => true,
        ])->assertStatus(201);

        $this->postJson("/api/admin/workflows/{$workflowId}/steps", [
            'step_key' => 'completed',
            'title' => 'Completed',
            'sequence' => 3,
            'is_terminal' => true,
        ])->assertStatus(201);

        $this->postJson("/api/admin/workflows/{$workflowId}/transitions", [
            'from_step_key' => 'accepted',
            'to_step_key' => 'ready',
        ])->assertOk();

        $this->postJson("/api/admin/workflows/{$workflowId}/transitions", [
            'from_step_key' => 'ready',
            'to_step_key' => 'completed',
        ])->assertOk();

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08022222222',
            'email' => 'seller2@test.local',
            'password' => 'password',
            'role' => UserRole::Seller,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $seller->id, 'zone_id' => $zone->id, 'type' => 'operational']);

        /** @var Shop $shop */
        $shop = Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
            'shop_type' => 'retail',
            'default_workflow_id' => null,
        ]);

        Sanctum::actingAs($seller);
        $this->postJson("/api/seller/shops/{$shop->id}/default-workflow", [
            'workflow_id' => $workflowId,
        ])->assertOk();

        $this->assertDatabaseHas('shops', [
            'id' => $shop->id,
            'default_workflow_id' => $workflowId,
        ]);
    }
}
