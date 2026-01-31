<?php

namespace Database\Seeders;

use App\Domain\Dispatch\Models\SellerRiderPool;
use App\Domain\Products\Models\Product;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Riders\Models\RiderProfile;
use App\Domain\Shops\Models\SellerBankAccount;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SampleUsersSeeder extends Seeder
{
    public function run(): void
    {
        $zone = Zone::query()->first() ?? Zone::create([
            'name' => 'Yaba',
            'city' => 'Lagos',
            'state' => 'Lagos',
            'is_active' => true,
        ]);

        $admin = User::updateOrCreate(
            ['phone' => '08000000001'],
            [
                'full_name' => 'Smartlink Admin',
                'email' => 'admin@smartlink.test',
                'password' => Hash::make('password'),
                'role' => UserRole::Admin,
                'status' => UserStatus::Active,
                'phone_verified_at' => now(),
                'email_verified_at' => now(),
            ],
        );

        $buyer = User::updateOrCreate(
            ['phone' => '08000000002'],
            [
                'full_name' => 'Smartlink Buyer',
                'email' => 'buyer@smartlink.test',
                'password' => Hash::make('password'),
                'role' => UserRole::Buyer,
                'status' => UserStatus::Active,
                'phone_verified_at' => now(),
                'email_verified_at' => now(),
            ],
        );

        UserZone::updateOrCreate(
            ['user_id' => $buyer->id, 'type' => 'home'],
            ['zone_id' => $zone->id],
        );

        $seller = User::updateOrCreate(
            ['phone' => '08000000003'],
            [
                'full_name' => 'Smartlink Seller',
                'email' => 'seller@smartlink.test',
                'password' => Hash::make('password'),
                'role' => UserRole::Seller,
                'status' => UserStatus::Active,
                'phone_verified_at' => now(),
                'email_verified_at' => now(),
            ],
        );

        UserZone::updateOrCreate(
            ['user_id' => $seller->id, 'type' => 'operational'],
            ['zone_id' => $zone->id],
        );

        $shop = Shop::updateOrCreate(
            ['seller_user_id' => $seller->id],
            [
                'shop_name' => 'Smartlink Electronics',
                'description' => 'Verified local electronics shop',
                'zone_id' => $zone->id,
                'country_code' => (string) config('smartlink.country_code', 'NG'),
                'state_code' => $zone->state,
                'city' => $zone->city,
                'address_text' => '1 Market Street',
                'is_verified' => true,
                'verification_phase' => 'phase1',
                'shipping_type' => 'local_rider',
            ],
        );

        SellerBankAccount::updateOrCreate(
            ['seller_user_id' => $seller->id],
            [
                'bank_name' => 'Demo Bank',
                'account_number' => '0000000000',
                'account_name' => 'Smartlink Seller',
                'verified_at' => now(),
            ],
        );

        $rider = User::updateOrCreate(
            ['phone' => '08000000004'],
            [
                'full_name' => 'Smartlink Rider',
                'email' => 'rider@smartlink.test',
                'password' => Hash::make('password'),
                'role' => UserRole::Rider,
                'status' => UserStatus::Active,
                'phone_verified_at' => now(),
                'email_verified_at' => now(),
            ],
        );

        UserZone::updateOrCreate(
            ['user_id' => $rider->id, 'type' => 'operational'],
            ['zone_id' => $zone->id],
        );

        RiderProfile::updateOrCreate(
            ['rider_user_id' => $rider->id],
            [
                'vehicle_type' => 'bike',
                'plate_number' => null,
                'is_elite' => true,
                'qr_code_token' => Str::uuid()->toString(),
            ],
        );

        RiderAvailability::updateOrCreate(
            ['rider_user_id' => $rider->id],
            ['status' => 'available', 'last_seen_at' => now()],
        );

        SellerRiderPool::updateOrCreate(
            ['shop_id' => $shop->id, 'rider_user_id' => $rider->id],
            ['status' => 'active', 'added_by' => $seller->id],
        );

        Product::updateOrCreate(
            ['shop_id' => $shop->id, 'name' => 'USB-C Charger'],
            [
                'description' => 'Fast charging adapter',
                'price' => 5000,
                'currency' => 'NGN',
                'stock_qty' => 50,
                'status' => 'active',
            ],
        );

        /** @var WalletService $walletService */
        $walletService = app(WalletService::class);
        $buyerWallet = $walletService->walletFor($buyer);

        $walletService->record(
            $buyerWallet,
            WalletTransactionType::Topup,
            WalletTransactionDirection::In,
            100000,
            'seed:buyer:topup',
            relatedEntityType: 'seeders',
            relatedEntityId: null,
            meta: ['actor_user_id' => $admin->id],
        );
    }
}
