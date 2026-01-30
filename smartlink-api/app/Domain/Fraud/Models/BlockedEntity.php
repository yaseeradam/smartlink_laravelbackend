<?php

namespace App\Domain\Fraud\Models;

use App\Domain\Fraud\Enums\BlockedEntityType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class BlockedEntity extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'type' => BlockedEntityType::class,
    ];
}
