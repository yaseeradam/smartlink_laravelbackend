<?php

namespace Tests\Feature;

use App\Domain\Orders\Enums\OrderStatus;
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
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OrderPlacementTest extends TestCase
{
    use RefreshDatabase;

    public function test_order_creation_holds_escrow(): void
    {
        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
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
            'shop_name' => 'Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
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
            'test:topup',
            meta: ['actor_user_id' => $buyer->id],
        );

        Sanctum::actingAs($buyer);

        $response = $this->postJson('/api/orders', [
            'shop_id' => $shop->id,
            'delivery_address_text' => 'Buyer Address',
            'items' => [
                ['product_id' => $product->id, 'qty' => 2],
            ],
        ]);

        $response->assertOk();
        $orderId = (int) $response->json('data.id');

        $this->assertDatabaseHas('orders', [
            'id' => $orderId,
            'status' => OrderStatus::Paid->value,
            'payment_status' => 'paid',
        ]);

        $this->assertDatabaseHas('escrow_holds', [
            'order_id' => $orderId,
            'status' => 'held',
        ]);

        $this->assertDatabaseHas('wallet_transactions', [
            'reference' => "order:{$orderId}:hold",
            'type' => 'hold',
            'direction' => 'out',
        ]);

        $buyerWallet->refresh();
        $this->assertSame('3000.00', (string) $buyerWallet->available_balance);
    }

    public function test_shipping_order_can_be_placed_for_non_local_shop(): void
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
            'phone' => '08011111112',
            'email' => 'buyer2@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $buyer->id, 'zone_id' => $buyerZone->id, 'type' => 'home']);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08022222223',
            'email' => 'seller2@test.local',
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
            'test:topup',
            meta: ['actor_user_id' => $buyer->id],
        );

        Sanctum::actingAs($buyer);

        $response = $this->postJson('/api/orders', [
            'shop_id' => $shop->id,
            'delivery_address_text' => 'Buyer Address',
            'items' => [
                ['product_id' => $product->id, 'qty' => 1],
            ],
        ]);

        $response->assertOk();

        $this->assertDatabaseHas('orders', [
            'shop_id' => $shop->id,
            'buyer_user_id' => $buyer->id,
            'fulfillment_mode' => 'shipping',
        ]);
    }
}
