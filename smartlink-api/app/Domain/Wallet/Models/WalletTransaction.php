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

    protected function casts(): array
    {
        return [
            'type' => WalletTransactionType::class,
            'direction' => WalletTransactionDirection::class,
            'amount' => 'decimal:2',
            'meta_json' => 'array',
        ];
    }

    public function walletAccount()
    {
        return $this->belongsTo(WalletAccount::class);
    }
}

