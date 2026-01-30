<?php

namespace App\Domain\Workflows\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WorkflowStep extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'sequence' => 'integer',
        'is_dispatch_trigger' => 'boolean',
        'is_terminal' => 'boolean',
    ];

    public function workflow()
    {
        return $this->belongsTo(Workflow::class);
    }

    public function outgoingTransitions()
    {
        return $this->hasMany(WorkflowStepTransition::class, 'from_step_id');
    }

    public function incomingTransitions()
    {
        return $this->hasMany(WorkflowStepTransition::class, 'to_step_id');
    }
}

