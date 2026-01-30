<?php

namespace App\Domain\Ratings\Models;

use App\Domain\Orders\Models\Order;
use App\Domain\Ratings\Enums\RateeType;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'ratee_type' => RateeType::class,
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function rater()
    {
        return $this->belongsTo(User::class, 'rater_user_id');
    }

    public function ratee()
    {
        return $this->belongsTo(User::class, 'ratee_user_id');
    }
}
