<?php

namespace App\Domain\Riders\Models;

use App\Domain\Riders\Enums\RiderAvailabilityStatus;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RiderAvailability extends Model
{
    use HasFactory;

    protected $table = 'rider_availability';

    protected $primaryKey = 'rider_user_id';
    public $incrementing = false;

    public $timestamps = false;

    protected $guarded = [];

    protected $casts = [
        'status' => RiderAvailabilityStatus::class,
        'last_seen_at' => 'datetime',
    ];

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_user_id');
    }
}
