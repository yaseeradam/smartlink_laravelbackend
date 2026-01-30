<?php

namespace App\Domain\Evidence\Models;

use App\Domain\Evidence\Enums\EvidenceType;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderEvidence extends Model
{
    use HasFactory;

    protected $table = 'order_evidence';

    protected $guarded = [];

    protected $casts = [
        'type' => EvidenceType::class,
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function capturedBy()
    {
        return $this->belongsTo(User::class, 'captured_by_user_id');
    }
}
