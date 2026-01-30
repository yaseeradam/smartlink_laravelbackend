<?php

namespace App\Domain\Disputes\Models;

use App\Domain\Disputes\Enums\DisputeReason;
use App\Domain\Disputes\Enums\DisputeResolution;
use App\Domain\Disputes\Enums\DisputeStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Dispute extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'reason' => DisputeReason::class,
        'status' => DisputeStatus::class,
        'resolution' => DisputeResolution::class,
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function raisedBy()
    {
        return $this->belongsTo(User::class, 'raised_by_user_id');
    }

    public function resolvedBy()
    {
        return $this->belongsTo(User::class, 'resolved_by_admin_id');
    }
}
