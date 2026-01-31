<?php

namespace Tests\Feature;

use App\Domain\Escrow\Jobs\AutoReleaseEscrowJob;
use App\Domain\Escrow\Models\EscrowHold;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Orders\Models\Order;
use App\Domain\Products\Models\Product;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ShippingFlowTest extends TestCase
{
    use RefreshDatabase;

    public function test_shipping_orders_cannot_create_dispatch_jobs(): void
    {
        [$buyer, $seller, $shop, $product, $orderId] = $this->createShippingOrder();

        Sanctum::actingAs($seller);
        $this->postJson("/api/orders/{$orderId}/dispatch")->assertStatus(409);
    }

    public function test_seller_cannot_mark_dropped_off_without_tracking_number_and_proof(): void
    {
        [$buyer, $seller, $shop, $product, $orderId] = $this->createShippingOrder();

        Sanctum::actingAs($seller);

        $this->postJson("/api/seller/orders/{$orderId}/shipping/create", [
            'courier_name' => 'DHL',
            'shipping_fee' => 2000,
            'eta_days_min' => 2,
            'eta_days_max' => 4,
        ])->assertStatus(201);

        $this->postJson("/api/seller/orders/{$orderId}/shipping/mark-dropped-off", [
            // missing tracking_number and proof_dropoff_url
        ])->assertStatus(422);
    }

    public function test_buyer_confirm_delivery_releases_escrow_for_shipping_orders(): void
    {
        [$buyer, $seller, $shop, $product, $orderId] = $this->createShippingOrder();

        Sanctum::actingAs($seller);

        $this->postJson("/api/seller/orders/{$orderId}/shipping/create", [
            'courier_name' => 'Seller Logistics',
            'shipping_fee' => 2500,
            'eta_days_min' => 2,
            'eta_days_max' => 5,
        ])->assertStatus(201);

        $this->postJson("/api/seller/orders/{$orderId}/shipping/update-status", [
            'status' => 'delivered',
            'proof_delivery_url' => 'https://example.test/proof-delivery.jpg',
        ])->assertOk();

        $this->assertDatabaseHas('orders', ['id' => $orderId, 'status' => 'delivered']);
        $this->assertDatabaseHas('shipments', ['order_id' => $orderId, 'status' => 'delivered']);

        Sanctum::actingAs($buyer);
        $resp = $this->postJson("/api/orders/{$orderId}/shipping/confirm-delivery")->assertOk();
        $resp->assertJsonPath('data.status', 'confirmed');
        $resp->assertJsonPath('data.shipment.status', 'confirmed');

        $this->assertDatabaseHas('escrow_holds', ['order_id' => $orderId, 'status' => 'released']);
    }

    public function test_auto_release_requires_delivered_shipment_for_shipping_orders(): void
    {
        [$buyer, $seller, $shop, $product, $orderId] = $this->createShippingOrder();

        Sanctum::actingAs($seller);
        $this->postJson("/api/seller/orders/{$orderId}/shipping/create", [
            'courier_name' => 'XX',
            'shipping_fee' => 1000,
            'eta_days_min' => 1,
            'eta_days_max' => 2,
        ])->assertStatus(201);

        $this->postJson("/api/seller/orders/{$orderId}/shipping/mark-packed")->assertOk();

        Order::query()->whereKey($orderId)->update(['status' => 'delivered']);
        EscrowHold::query()->where('order_id', $orderId)->update(['hold_expires_at' => now()->subHour()]);

        $hold = EscrowHold::query()->where('order_id', $orderId)->firstOrFail();
        (new AutoReleaseEscrowJob($hold->id))->handle(app(EscrowService::class));

        $hold->refresh();
        $this->assertSame('held', $hold->status->value);
    }

    public function test_auto_release_happens_after_delivered_and_timeout_for_shipping_orders(): void
    {
        [$buyer, $seller, $shop, $product, $orderId] = $this->createShippingOrder();

        Sanctum::actingAs($seller);
        $this->postJson("/api/seller/orders/{$orderId}/shipping/create", [
            'courier_name' => 'XX',
            'shipping_fee' => 1000,
            'eta_days_min' => 1,
            'eta_days_max' => 2,
        ])->assertStatus(201);

        $this->postJson("/api/seller/orders/{$orderId}/shipping/update-status", [
            'status' => 'delivered',
        ])->assertOk();

        EscrowHold::query()->where('order_id', $orderId)->update(['hold_expires_at' => now()->subHour()]);

        $hold = EscrowHold::query()->where('order_id', $orderId)->firstOrFail();
        (new AutoReleaseEscrowJob($hold->id))->handle(app(EscrowService::class));

        $hold->refresh();
        $this->assertSame('released', $hold->status->value);
    }

    /**
     * @return array{0:User,1:User,2:Shop,3:Product,4:int}
     */
    private function createShippingOrder(): array
    {
        $buyerZone = Zone::create([
            'name' => 'Buyer Zone',
            'city' => 'Buyer City',
            'state' => 'Buyer State',
            'is_active' => true,
            'status' => 'active',
        ]);
        $shopZone = Zone::create([
            'name' => 'Shop Zone',
            'city' => 'Shop City',
            'state' => 'Shop State',
            'is_active' => true,
            'status' => 'active',
        ]);

        $buyer = User::create([
            'full_name' => 'Buyer',
            'phone' => '08033000001',
            'email' => 'buyer-ship@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);
        UserZone::create(['user_id' => $buyer->id, 'zone_id' => $buyerZone->id, 'type' => 'home']);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08033000002',
            'email' => 'seller-ship@test.local',
            'password' => 'password',
            'role' => UserRole::Seller,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);
        UserZone::create(['user_id' => $seller->id, 'zone_id' => $shopZone->id, 'type' => 'operational']);

        $shop = Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Shop',
            'description' => null,
            'zone_id' => $shopZone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
            'shipping_type' => 'state_shipping',
        ]);

        $product = Product::create([
            'shop_id' => $shop->id,
            'name' => 'Item',
            'description' => null,
            'price' => 1000,
            'currency' => 'NGN',
            'stock_qty' => 10,
            'status' => 'active',
        ]);

        /** @var WalletService $walletService */
        $walletService = app(WalletService::class);
        $buyerWallet = $walletService->walletFor($buyer);
        $walletService->record(
            $buyerWallet,
            WalletTransactionType::Topup,
            WalletTransactionDirection::In,
            5000,
            'test:topup:shipping',
            meta: ['actor_user_id' => $buyer->id],
        );

        Sanctum::actingAs($buyer);
        $resp = $this->postJson('/api/orders', [
            'shop_id' => $shop->id,
            'delivery_address_text' => 'Buyer Address',
            'items' => [
                ['product_id' => $product->id, 'qty' => 1],
            ],
        ])->assertOk();

        $orderId = (int) $resp->json('data.id');

        $this->assertDatabaseHas('orders', [
            'id' => $orderId,
            'fulfillment_mode' => 'shipping',
        ]);

        return [$buyer, $seller, $shop, $product, $orderId];
    }
}
