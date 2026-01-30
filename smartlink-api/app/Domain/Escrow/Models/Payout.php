<?php

namespace App\Domain\Escrow\Models;

use App\Domain\Escrow\Enums\PayoutProvider;
use App\Domain\Escrow\Enums\PayoutStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payout extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'amount' => 'decimal:2',
        'status' => PayoutStatus::class,
        'provider' => PayoutProvider::class,
    ];

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_user_id');
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
