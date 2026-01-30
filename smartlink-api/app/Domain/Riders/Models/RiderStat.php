<?php

namespace App\Domain\Riders\Models;

use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RiderStat extends Model
{
    use HasFactory;

    protected $primaryKey = 'rider_user_id';

    public $incrementing = false;

    protected $guarded = [];

    protected $casts = [
        'acceptance_rate' => 'decimal:2',
        'cancellation_rate' => 'decimal:2',
        'avg_delivery_time' => 'decimal:2',
    ];

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_user_id');
    }
}
