<?php

namespace App\Domain\Wallet\Models;

use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletAccountStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WalletAccount extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'available_balance' => 'decimal:2',
            'status' => WalletAccountStatus::class,
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function transactions()
    {
        return $this->hasMany(WalletTransaction::class);
    }
}

