<?php

namespace App\Domain\Recommendations\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ShopTrustMetric extends Model
{
    use HasFactory;

    protected $primaryKey = 'shop_id';

    public $incrementing = false;

    protected $keyType = 'int';

    protected $guarded = [];

    protected $casts = [
        'trust_score' => 'decimal:2',
        'dispute_rate' => 'decimal:6',
        'cancellation_rate' => 'decimal:6',
        'fulfillment_success_rate' => 'decimal:6',
        'rating_bayesian' => 'decimal:3',
        'last_calculated_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}

