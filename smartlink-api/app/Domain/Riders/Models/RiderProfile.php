<?php

namespace App\Domain\Riders\Models;

use App\Domain\Riders\Enums\VehicleType;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RiderProfile extends Model
{
    use HasFactory;

    protected $primaryKey = 'rider_user_id';
    public $incrementing = false;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'vehicle_type' => VehicleType::class,
            'is_elite' => 'boolean',
        ];
    }

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_user_id');
    }
}

