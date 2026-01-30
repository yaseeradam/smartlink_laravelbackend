<?php

namespace App\Domain\Escrow\Models;

use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Models\WalletAccount;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EscrowHold extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'amount' => 'decimal:2',
        'status' => EscrowStatus::class,
        'hold_expires_at' => 'datetime',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function buyerWalletAccount()
    {
        return $this->belongsTo(WalletAccount::class, 'buyer_wallet_account_id');
    }

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_user_id');
    }
}
