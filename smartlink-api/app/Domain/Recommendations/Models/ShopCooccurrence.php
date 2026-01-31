<?php

namespace App\Domain\Recommendations\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ShopCooccurrence extends Model
{
    use HasFactory;

    protected $table = 'shop_cooccurrence';

    public $timestamps = false;

    protected $guarded = [];

    protected $casts = [
        'weight' => 'decimal:6',
        'updated_at' => 'datetime',
    ];
}
