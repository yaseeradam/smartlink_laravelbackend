<?php

namespace Tests\Feature;

use App\Domain\Admin\Models\AdminUser;
use App\Domain\Escrow\Models\EscrowHold;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Workflows\Models\WorkflowStep;
use App\Domain\Zones\Models\Zone;
use Database\Seeders\WorkflowsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminModuleTest extends TestCase
{
    use RefreshDatabase;

    public function test_admin_auth_is_required(): void
    {
        $this->getJson('/api/admin/orders')->assertStatus(401);
    }

    public function test_reason_is_required_for_admin_mutations(): void
    {
        $admin = $this->createAdmin();
        $order = $this->createPaidOrderWithEscrowHold()['order'];

        Sanctum::actingAs($admin, [], 'admin');

        $this->postJson("/api/admin/orders/{$order->id}/pause")
            ->assertStatus(422)
            ->assertJson(['message' => 'reason is required.']);
    }

    public function test_admin_mutation_creates_audit_log(): void
    {
        $admin = $this->createAdmin();
        $order = $this->createPaidOrderWithEscrowHold()['order'];

        Sanctum::actingAs($admin, [], 'admin');

        $this->postJson("/api/admin/orders/{$order->id}/pause", ['reason' => 'maintenance'])
            ->assertOk();

        $this->assertDatabaseHas('admin_action_logs', [
            'admin_user_id' => $admin->id,
            'action_type' => 'order.pause',
            'entity_type' => 'order',
            'entity_id' => $order->id,
            'reason' => 'maintenance',
        ]);

        $row = DB::table('admin_action_logs')->where('action_type', 'order.pause')->first();
        $this->assertNotNull($row);
        $old = json_decode((string) $row->old_state, true);
        $new = json_decode((string) $row->new_state, true);
        $this->assertIsArray($old);
        $this->assertIsArray($new);
        $this->assertNull($old['admin_paused_at'] ?? null);
        $this->assertNotNull($new['admin_paused_at'] ?? null);
    }

    public function test_force_release_escrow_calls_existing_service_and_logs(): void
    {
        $admin = $this->createAdmin();
        $created = $this->createPaidOrderWithEscrowHold();
        $order = $created['order'];
        $hold = $created['hold'];

        Sanctum::actingAs($admin, [], 'admin');

        $mock = $this->mock(EscrowService::class);
        $mock->shouldReceive('release')
            ->once()
            ->withArgs(function ($passedHold, $actorUserId) use ($hold) {
                return (int) $passedHold->id === (int) $hold->id && $actorUserId === null;
            });

        $this->postJson("/api/admin/orders/{$order->id}/force-release-escrow", ['reason' => 'manual release'])
            ->assertOk();

        $this->assertDatabaseHas('admin_action_logs', [
            'admin_user_id' => $admin->id,
            'action_type' => 'escrow.force_release',
            'entity_type' => 'order',
            'entity_id' => $order->id,
            'reason' => 'manual release',
        ]);
    }

    public function test_workflow_override_changes_step_and_logs_before_after(): void
    {
        $admin = $this->createAdmin();

        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
            'status' => 'active',
        ]);

        $buyer = User::create([
            'full_name' => 'Buyer',
            'phone' => '08011111161',
            'email' => 'buyer61@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08022222261',
            'email' => 'seller61@test.local',
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
            'shop_type' => 'retail',
            'default_workflow_id' => null,
        ]);

        $this->seed(WorkflowsSeeder::class);
        $shop->refresh();

        $order = Order::create([
            'buyer_user_id' => $buyer->id,
            'shop_id' => $shop->id,
            'zone_id' => $shop->zone_id,
            'order_kind' => 'product',
            'service_type' => 'retail',
            'subtotal_amount' => 1000,
            'delivery_fee_amount' => 0,
            'rider_share_amount' => 0,
            'platform_fee_amount' => 0,
            'total_amount' => 1000,
            'status' => OrderStatus::Paid,
            'payment_status' => OrderPaymentStatus::Paid,
            'delivery_address_text' => 'Buyer Address',
        ]);

        $readyStep = WorkflowStep::query()
            ->where('workflow_id', $shop->default_workflow_id)
            ->where('step_key', 'ready')
            ->firstOrFail();

        Sanctum::actingAs($admin, [], 'admin');

        $this->postJson("/api/admin/orders/{$order->id}/override-workflow-step", [
            'to_step_key' => 'ready',
            'reason' => 'admin override',
        ])->assertOk();

        $order->refresh();
        $this->assertSame($readyStep->id, $order->workflow_step_id);

        $row = DB::table('admin_action_logs')->where('action_type', 'order.override_workflow_step')->first();
        $this->assertNotNull($row);
        $old = json_decode((string) $row->old_state, true);
        $new = json_decode((string) $row->new_state, true);
        $this->assertNull($old['workflow_step_id'] ?? null);
        $this->assertSame($readyStep->id, $new['workflow_step_id'] ?? null);
    }

    private function createAdmin(): AdminUser
    {
        return AdminUser::create([
            'name' => 'Super Admin',
            'email' => 'admin@test.local',
            'password_hash' => Hash::make('secret'),
            'is_active' => true,
            'last_login_at' => null,
        ]);
    }

    /**
     * @return array{order:Order, hold:EscrowHold}
     */
    private function createPaidOrderWithEscrowHold(): array
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
            'phone' => '08011111121',
            'email' => 'buyer21@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08022222221',
            'email' => 'seller21@test.local',
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
        ]);

        $order = Order::create([
            'buyer_user_id' => $buyer->id,
            'shop_id' => $shop->id,
            'zone_id' => $zone->id,
            'order_kind' => 'product',
            'service_type' => 'retail',
            'subtotal_amount' => 1000,
            'delivery_fee_amount' => 0,
            'rider_share_amount' => 0,
            'platform_fee_amount' => 0,
            'total_amount' => 1000,
            'status' => OrderStatus::Paid,
            'payment_status' => OrderPaymentStatus::Paid,
            'delivery_address_text' => 'Buyer Address',
        ]);

        $hold = EscrowHold::create([
            'order_id' => $order->id,
            'buyer_wallet_account_id' => $buyer->walletAccount()->firstOrFail()->id,
            'seller_user_id' => $seller->id,
            'amount' => 1000,
            'status' => 'held',
            'hold_expires_at' => null,
        ]);

        return ['order' => $order, 'hold' => $hold];
    }
}

