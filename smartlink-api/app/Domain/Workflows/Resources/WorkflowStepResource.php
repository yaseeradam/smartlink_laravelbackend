<?php

namespace App\Domain\Workflows\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkflowStepResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Workflows\Models\WorkflowStep $step */
        $step = $this->resource;

        return [
            'id' => $step->id,
            'workflow_id' => $step->workflow_id,
            'step_key' => $step->step_key,
            'title' => $step->title,
            'sequence' => (int) $step->sequence,
            'is_dispatch_trigger' => (bool) $step->is_dispatch_trigger,
            'is_terminal' => (bool) $step->is_terminal,
        ];
    }
}

