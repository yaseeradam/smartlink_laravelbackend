<?php

namespace App\Domain\Shipping\Models;

use App\Domain\Orders\Models\Order;
use App\Domain\Shipping\Enums\ShipmentShippingType;
use App\Domain\Shipping\Enums\ShipmentStatus;
use Illuminate\Database\Eloquent\Model;

class Shipment extends Model
{
    protected $guarded = [];

    protected $casts = [
        'shipping_type' => ShipmentShippingType::class,
        'status' => ShipmentStatus::class,
        'shipping_fee' => 'decimal:2',
        'eta_days_min' => 'integer',
        'eta_days_max' => 'integer',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function timeline()
    {
        return $this->hasMany(ShipmentStatusHistory::class)->orderBy('id');
    }
}

