<?php

namespace App\Domain\Orders\Models;

use App\Domain\Users\Models\User;
use App\Domain\Workflows\Models\WorkflowStep;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderWorkflowEvent extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $guarded = [];

    protected $casts = [
        'created_at' => 'datetime',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function fromStep()
    {
        return $this->belongsTo(WorkflowStep::class, 'from_step_id');
    }

    public function toStep()
    {
        return $this->belongsTo(WorkflowStep::class, 'to_step_id');
    }

    public function changedBy()
    {
        return $this->belongsTo(User::class, 'changed_by_user_id');
    }
}

