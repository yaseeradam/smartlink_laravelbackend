<?php

namespace App\Domain\Shops\Models;

use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SellerBankAccount extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'verified_at' => 'datetime',
    ];

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_user_id');
    }
}
