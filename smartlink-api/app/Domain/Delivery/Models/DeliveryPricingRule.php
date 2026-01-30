<?php

namespace App\Domain\Delivery\Models;

use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeliveryPricingRule extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'base_fee' => 'decimal:2',
        'max_distance_km' => 'decimal:2',
        'rider_share_percent' => 'decimal:2',
        'platform_fee_percent' => 'decimal:2',
    ];

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }
}
