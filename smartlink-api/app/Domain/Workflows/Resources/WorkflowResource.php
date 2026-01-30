<?php

namespace App\Domain\Workflows\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WorkflowResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Workflows\Models\Workflow $workflow */
        $workflow = $this->resource;

        return [
            'id' => $workflow->id,
            'code' => $workflow->code,
            'name' => $workflow->name,
            'is_active' => (bool) $workflow->is_active,
            'steps' => WorkflowStepResource::collection($this->whenLoaded('steps')),
            'transitions' => $this->whenLoaded('transitions', function () use ($workflow) {
                return $workflow->transitions->map(function ($t) {
                    return [
                        'from_step_id' => $t->from_step_id,
                        'to_step_id' => $t->to_step_id,
                        'from_step_key' => $t->fromStep?->step_key,
                        'to_step_key' => $t->toStep?->step_key,
                    ];
                })->values();
            }),
        ];
    }
}

