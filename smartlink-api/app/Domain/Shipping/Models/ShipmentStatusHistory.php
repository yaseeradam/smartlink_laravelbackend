<?php

namespace App\Domain\Shipping\Models;

use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Model;

class ShipmentStatusHistory extends Model
{
    protected $table = 'shipment_status_history';

    protected $guarded = [];

    protected $casts = [
        'meta_json' => 'array',
    ];

    public function shipment()
    {
        return $this->belongsTo(Shipment::class);
    }

    public function changedBy()
    {
        return $this->belongsTo(User::class, 'changed_by_user_id');
    }
}

