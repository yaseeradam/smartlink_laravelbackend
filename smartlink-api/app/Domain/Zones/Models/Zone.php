<?php

namespace App\Domain\Zones\Models;

use App\Domain\Orders\Models\Order;
use App\Domain\Shops\Models\Shop;
use App\Domain\Zones\Enums\ZoneStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Zone extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'polygon_geojson' => 'array',
        'is_active' => 'boolean',
        'status' => ZoneStatus::class,
    ];

    public function shops()
    {
        return $this->hasMany(Shop::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}
