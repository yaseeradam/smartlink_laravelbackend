<?php

namespace App\Domain\Shipping\Models;

use Illuminate\Database\Eloquent\Model;

class ShippingRate extends Model
{
    protected $guarded = [];

    protected $casts = [
        'fee' => 'decimal:2',
        'eta_days_min' => 'integer',
        'eta_days_max' => 'integer',
    ];
}

