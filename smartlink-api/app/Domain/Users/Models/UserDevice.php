<?php

namespace App\Domain\Users\Models;

use App\Domain\Users\Enums\DevicePlatform;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserDevice extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'platform' => DevicePlatform::class,
        'last_seen_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
