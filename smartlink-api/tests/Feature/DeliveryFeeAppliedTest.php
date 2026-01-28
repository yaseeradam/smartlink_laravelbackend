<?php

namespace Tests\Feature;

use App\Domain\Delivery\Models\DeliveryPricingRule;
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

class DeliveryFeeAppliedTest extends TestCase
{
    use RefreshDatabase;

    public function test_delivery_fee_breakdown_is_stored_on_order(): void
    {
        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
            'status' => 'active',
        ]);

        DeliveryPricingRule::create([
            'zone_id' => $zone->id,
            'base_fee' => 200,
            'max_distance_km' => null,
            'rider_share_percent' => 60,
            'platform_fee_percent' => 40,
        ]);

        $buyer = User::create([
            'full_name' => 'Buyer',
            'phone' => '08099990001',
            'email' => 'buyer-fee@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $buyer->id, 'zone_id' => $zone->id, 'type' => 'home']);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08099990002',
            'email' => 'seller-fee@test.local',
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
            'test:topup:fee',
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
        $orderId = (int) $response->json('data.id');

        $order = Order::query()->findOrFail($orderId);
        $this->assertSame('200.00', (string) $order->delivery_fee_amount);
        $this->assertSame('120.00', (string) $order->rider_share_amount);
        $this->assertSame('80.00', (string) $order->platform_fee_amount);
        $this->assertSame('1200.00', (string) $order->total_amount);
    }
}
