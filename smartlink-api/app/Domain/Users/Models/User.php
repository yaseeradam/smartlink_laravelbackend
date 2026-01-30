<?php

namespace App\Domain\Users\Models;

use App\Domain\Kyc\Models\KycRequest;
use App\Domain\Orders\Models\Order;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Wallet\Models\WalletAccount;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;
    use HasFactory;
    use Notifiable;

    protected $guarded = [];

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'role' => UserRole::class,
        'status' => UserStatus::class,
        'phone_verified_at' => 'datetime',
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];

    protected static function booted(): void
    {
        static::created(function (self $user): void {
            WalletAccount::firstOrCreate(
                ['user_id' => $user->id],
                [
                    'currency' => (string) config('smartlink.currency', 'NGN'),
                    'available_balance' => 0,
                    'status' => 'active',
                ],
            );
        });
    }

    public function walletAccount()
    {
        return $this->hasOne(WalletAccount::class);
    }

    public function shop()
    {
        return $this->hasOne(Shop::class, 'seller_user_id')->latestOfMany();
    }

    public function shops()
    {
        return $this->hasMany(Shop::class, 'seller_user_id');
    }

    public function kycRequests()
    {
        return $this->hasMany(KycRequest::class);
    }

    public function buyerOrders()
    {
        return $this->hasMany(Order::class, 'buyer_user_id');
    }

    public function zones()
    {
        return $this->hasMany(UserZone::class);
    }

    public function devices()
    {
        return $this->hasMany(UserDevice::class);
    }

    public function hasVerifiedPhone(): bool
    {
        return $this->phone_verified_at !== null;
    }
}
