<?php

namespace App\Domain\Admin\Models;

use Illuminate\Database\Eloquent\Model;

class AdminActionLog extends Model
{
    protected $table = 'admin_action_logs';

    public $timestamps = false;

    protected $guarded = [];

    protected $casts = [
        'old_state' => 'array',
        'new_state' => 'array',
        'created_at' => 'datetime',
    ];

    public function adminUser()
    {
        return $this->belongsTo(AdminUser::class, 'admin_user_id');
    }
}

