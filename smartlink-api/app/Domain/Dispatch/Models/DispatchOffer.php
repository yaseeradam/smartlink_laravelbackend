<?php

namespace App\Domain\Dispatch\Models;

use App\Domain\Dispatch\Enums\DispatchOfferStatus;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DispatchOffer extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'offer_status' => DispatchOfferStatus::class,
            'offered_at' => 'datetime',
            'responded_at' => 'datetime',
        ];
    }

    public function job()
    {
        return $this->belongsTo(DispatchJob::class, 'dispatch_job_id');
    }

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_user_id');
    }
}

