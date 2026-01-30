<?php

namespace App\Domain\Kyc\Models;

use App\Domain\Kyc\Enums\KycStatus;
use App\Domain\Kyc\Enums\KycType;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KycRequest extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'kyc_type' => KycType::class,
        'status' => KycStatus::class,
        'submitted_at' => 'datetime',
        'reviewed_at' => 'datetime',
        'meta_json' => 'array',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function documents()
    {
        return $this->hasMany(KycDocument::class);
    }

    public function reviewer()
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }
}
