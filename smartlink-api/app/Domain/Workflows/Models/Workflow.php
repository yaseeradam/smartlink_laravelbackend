<?php

namespace App\Domain\Workflows\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Workflow extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'is_active' => 'boolean',
    ];

    public function steps()
    {
        return $this->hasMany(WorkflowStep::class)->orderBy('sequence');
    }

    public function transitions()
    {
        return $this->hasMany(WorkflowStepTransition::class);
    }
}

