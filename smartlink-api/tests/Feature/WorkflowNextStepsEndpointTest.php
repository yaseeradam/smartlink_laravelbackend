<?php

namespace Tests\Feature;

use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\Zone;
use Database\Seeders\WorkflowsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class WorkflowNextStepsEndpointTest extends TestCase
{
    use RefreshDatabase;

    public function test_next_steps_returns_allowed_transitions(): void
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

        $shop = Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Food Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
            'shop_type' => 'food',
            'default_workflow_id' => \App\Domain\Workflows\Models\Workflow::query()->where('code', 'food')->value('id'),
        ]);

        $order = Order::create([
            'buyer_user_id' => 1,
            'shop_id' => $shop->id,
            'order_kind' => 'product',
            'service_type' => 'food',
            'workflow_id' => $shop->default_workflow_id,
            'zone_id' => $shop->zone_id,
            'subtotal_amount' => 1000,
            'delivery_fee_amount' => 0,
            'rider_share_amount' => 0,
            'platform_fee_amount' => 0,
            'total_amount' => 1000,
            'status' => OrderStatus::Paid,
            'payment_status' => OrderPaymentStatus::Paid,
            'delivery_address_text' => 'Buyer Address',
        ]);

        Sanctum::actingAs($seller);
        $this->postJson("/api/seller/orders/{$order->id}/workflow/start")->assertOk();

        $resp = $this->getJson("/api/seller/orders/{$order->id}/workflow/next-steps")->assertOk();

        $keys = collect($resp->json('data'))->pluck('step_key')->all();
        $this->assertContains('cooking', $keys);
        $this->assertContains('baking', $keys);
    }
}

