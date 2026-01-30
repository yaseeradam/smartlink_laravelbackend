<?php

namespace App\Domain\Wallet\Models;

use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WalletTransaction extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'type' => WalletTransactionType::class,
        'direction' => WalletTransactionDirection::class,
        'amount' => 'decimal:2',
        'meta_json' => 'json',
    ];

    public function walletAccount()
    {
        return $this->belongsTo(WalletAccount::class);
    }
}
