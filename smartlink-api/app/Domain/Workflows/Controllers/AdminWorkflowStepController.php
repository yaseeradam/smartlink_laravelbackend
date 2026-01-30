<?php

namespace App\Domain\Workflows\Controllers;

use App\Domain\Workflows\Models\Workflow;
use App\Domain\Workflows\Models\WorkflowStep;
use App\Domain\Workflows\Requests\AdminUpsertWorkflowStepRequest;
use App\Domain\Workflows\Resources\WorkflowStepResource;
use App\Domain\Workflows\Services\WorkflowTemplateService;

class AdminWorkflowStepController
{
    public function __construct(private readonly WorkflowTemplateService $workflowTemplateService)
    {
    }

    public function store(AdminUpsertWorkflowStepRequest $request, Workflow $workflow)
    {
        $data = $request->validated();

        try {
            $step = $this->workflowTemplateService->addStep($workflow, [
                'step_key' => (string) $data['step_key'],
                'title' => (string) $data['title'],
                'sequence' => (int) $data['sequence'],
                'is_dispatch_trigger' => (bool) ($data['is_dispatch_trigger'] ?? false),
                'is_terminal' => (bool) ($data['is_terminal'] ?? false),
            ]);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new WorkflowStepResource($step);
    }

    public function update(AdminUpsertWorkflowStepRequest $request, WorkflowStep $workflowStep)
    {
        $data = $request->validated();

        try {
            $updated = $this->workflowTemplateService->updateStep($workflowStep, $data);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new WorkflowStepResource($updated);
    }

    public function destroy(WorkflowStep $workflowStep)
    {
        $this->workflowTemplateService->deleteStep($workflowStep);

        return response()->json(['message' => 'Deleted.']);
    }
}

