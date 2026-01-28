<?php

namespace App\Domain\Zones\Models;

use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserZone extends Model
{
    use HasFactory;

    protected $table = 'user_zones';

    protected $guarded = [];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }
}

