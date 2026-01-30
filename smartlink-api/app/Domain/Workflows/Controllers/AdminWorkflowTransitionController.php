<?php

namespace App\Domain\Workflows\Controllers;

use App\Domain\Workflows\Models\Workflow;
use App\Domain\Workflows\Requests\AdminUpsertWorkflowTransitionRequest;
use App\Domain\Workflows\Services\WorkflowTemplateService;

class AdminWorkflowTransitionController
{
    public function __construct(private readonly WorkflowTemplateService $workflowTemplateService)
    {
    }

    public function store(AdminUpsertWorkflowTransitionRequest $request, Workflow $workflow)
    {
        $data = $request->validated();

        try {
            $transition = $this->workflowTemplateService->addTransition(
                $workflow,
                (string) $data['from_step_key'],
                (string) $data['to_step_key'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'id' => $transition->id,
            'workflow_id' => $transition->workflow_id,
            'from_step_id' => $transition->from_step_id,
            'to_step_id' => $transition->to_step_id,
        ]);
    }

    public function destroy(AdminUpsertWorkflowTransitionRequest $request, Workflow $workflow)
    {
        $data = $request->validated();

        $this->workflowTemplateService->deleteTransition(
            $workflow,
            (string) $data['from_step_key'],
            (string) $data['to_step_key'],
        );

        return response()->json(['message' => 'Deleted.']);
    }
}

