<?php

namespace App\Domain\Workflows\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WorkflowStepTransition extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $guarded = [];

    public function workflow()
    {
        return $this->belongsTo(Workflow::class);
    }

    public function fromStep()
    {
        return $this->belongsTo(WorkflowStep::class, 'from_step_id');
    }

    public function toStep()
    {
        return $this->belongsTo(WorkflowStep::class, 'to_step_id');
    }
}

