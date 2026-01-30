<?php

namespace App\Domain\Dispatch\Models;

use App\Domain\Dispatch\Enums\DispatchJobStatus;
use App\Domain\Dispatch\Enums\DispatchPurpose;
use App\Domain\Orders\Models\Order;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DispatchJob extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'status' => DispatchJobStatus::class,
        'purpose' => DispatchPurpose::class,
        'private_pool_only_until' => 'datetime',
        'fallback_broadcast_at' => 'datetime',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function assignedRider()
    {
        return $this->belongsTo(User::class, 'assigned_rider_user_id');
    }

    public function offers()
    {
        return $this->hasMany(DispatchOffer::class);
    }
}
