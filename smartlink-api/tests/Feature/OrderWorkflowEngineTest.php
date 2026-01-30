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
use Illuminate\Support\Facades\Bus;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OrderWorkflowEngineTest extends TestCase
{
    use RefreshDatabase;

    public function test_invalid_step_transition_is_blocked(): void
    {
        [$buyer, $seller, $shop] = $this->setupSellerAndShop('food');
        $this->seed(WorkflowsSeeder::class);
        $shop->refresh();

        $order = $this->makePaidOrder($buyer, $shop, serviceType: 'food');

        Sanctum::actingAs($seller);
        $this->postJson("/api/seller/orders/{$order->id}/workflow/start")->assertOk();

        $this->postJson("/api/seller/orders/{$order->id}/workflow/advance", [
            'to_step_key' => 'ready_for_pickup',
        ])->assertStatus(422);
    }

    public function test_dispatch_is_blocked_before_dispatch_trigger_step(): void
    {
        [$buyer, $seller, $shop] = $this->setupSellerAndShop('food');
        $this->seed(WorkflowsSeeder::class);
        $shop->refresh();

        $order = $this->makePaidOrder($buyer, $shop, serviceType: 'food');

        Sanctum::actingAs($seller);
        $this->postJson("/api/seller/orders/{$order->id}/workflow/start")->assertOk();

        $this->postJson("/api/orders/{$order->id}/dispatch")
            ->assertStatus(409);

        $this->assertDatabaseMissing('dispatch_jobs', [
            'order_id' => $order->id,
            'purpose' => 'delivery',
        ]);
    }

    public function test_repair_cannot_move_to_repairing_without_quote_approval(): void
    {
        [$buyer, $seller, $shop] = $this->setupSellerAndShop('repair');
        $this->seed(WorkflowsSeeder::class);
        $shop->refresh();

        $order = Order::create([
            'buyer_user_id' => $buyer->id,
            'shop_id' => $shop->id,
            'order_kind' => 'service',
            'service_type' => 'repair',
            'workflow_id' => $shop->default_workflow_id,
            'zone_id' => $shop->zone_id,
            'subtotal_amount' => 0,
            'delivery_fee_amount' => 0,
            'rider_share_amount' => 0,
            'platform_fee_amount' => 0,
            'total_amount' => 0,
            'status' => OrderStatus::Placed,
            'payment_status' => OrderPaymentStatus::Pending,
            'delivery_address_text' => 'Addr',
            'issue_description' => 'Broken screen',
        ]);

        Sanctum::actingAs($seller);
        $this->postJson("/api/seller/orders/{$order->id}/workflow/start")->assertOk();
        $this->postJson("/api/seller/orders/{$order->id}/workflow/advance", ['to_step_key' => 'accepted'])->assertOk();
        $this->postJson("/api/seller/orders/{$order->id}/workflow/advance", ['to_step_key' => 'diagnosing'])->assertOk();
        $this->postJson("/api/seller/orders/{$order->id}/workflow/advance", ['to_step_key' => 'quote_sent'])->assertOk();
        $this->postJson("/api/seller/orders/{$order->id}/workflow/advance", ['to_step_key' => 'awaiting_approval'])->assertOk();

        $this->postJson("/api/seller/orders/{$order->id}/workflow/advance", ['to_step_key' => 'repairing'])
            ->assertStatus(409);
    }

    public function test_entering_dispatch_trigger_step_creates_dispatch_job(): void
    {
        Bus::fake();

        [$buyer, $seller, $shop] = $this->setupSellerAndShop('food');
        $this->seed(WorkflowsSeeder::class);
        $shop->refresh();

        $order = $this->makePaidOrder($buyer, $shop, serviceType: 'food');

        Sanctum::actingAs($seller);

        $this->postJson("/api/seller/orders/{$order->id}/workflow/start")->assertOk();
        $this->postJson("/api/seller/orders/{$order->id}/workflow/advance", ['to_step_key' => 'cooking'])->assertOk();
        $this->postJson("/api/seller/orders/{$order->id}/workflow/advance", ['to_step_key' => 'ready_for_pickup'])->assertOk();

        $this->assertDatabaseHas('dispatch_jobs', [
            'order_id' => $order->id,
            'purpose' => 'delivery',
        ]);
    }

    /**
     * @return array{0:User, 1:User, 2:Shop}
     */
    private function setupSellerAndShop(string $shopType): array
    {
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
            'shop_name' => 'Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
            'shop_type' => $shopType,
            'default_workflow_id' => null,
        ]);

        return [$buyer, $seller, $shop];
    }

    private function makePaidOrder(User $buyer, Shop $shop, string $serviceType): Order
    {
        return Order::create([
            'buyer_user_id' => $buyer->id,
            'shop_id' => $shop->id,
            'order_kind' => 'product',
            'service_type' => $serviceType,
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
    }
}

