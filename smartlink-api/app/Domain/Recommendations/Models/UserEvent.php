<?php

namespace App\Domain\Recommendations\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserEvent extends Model
{
    use HasFactory;

    protected $table = 'user_events';

    public $timestamps = false;

    protected $guarded = [];

    protected $casts = [
        'meta_json' => 'array',
        'created_at' => 'datetime',
    ];
}
