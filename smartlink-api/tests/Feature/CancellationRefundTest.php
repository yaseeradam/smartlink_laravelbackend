<?php

namespace Tests\Feature;

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

class CancellationRefundTest extends TestCase
{
    use RefreshDatabase;

    public function test_buyer_cancellation_refunds_and_restores_stock(): void
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
            'phone' => '08099990021',
            'email' => 'buyer-cancel@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $buyer->id, 'zone_id' => $zone->id, 'type' => 'home']);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08099990022',
            'email' => 'seller-cancel@test.local',
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
            'stock_qty' => 5,
            'status' => 'active',
        ]);

        /** @var WalletService $walletService */
        $walletService = app(WalletService::class);
        $buyerWallet = $walletService->walletFor($buyer);
        $walletService->record(
            $buyerWallet,
            WalletTransactionType::Topup,
            WalletTransactionDirection::In,
            10000,
            'test:topup:cancel',
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

        $product->refresh();
        $this->assertSame(3, $product->stock_qty);

        $cancel = $this->postJson("/api/orders/{$orderId}/cancel", [
            'reason' => 'Changed my mind',
        ]);

        $cancel->assertOk();

        $this->assertDatabaseHas('orders', [
            'id' => $orderId,
            'status' => 'cancelled',
            'payment_status' => 'refunded',
        ]);

        $this->assertDatabaseHas('wallet_transactions', [
            'reference' => "escrow:order:{$orderId}:refund",
            'type' => 'refund',
        ]);

        $product->refresh();
        $this->assertSame(5, $product->stock_qty);
    }
}
