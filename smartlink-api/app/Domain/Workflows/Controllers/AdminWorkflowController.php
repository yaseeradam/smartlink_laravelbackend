<?php

namespace App\Domain\Workflows\Controllers;

use App\Domain\Workflows\Models\Workflow;
use App\Domain\Workflows\Requests\AdminUpsertWorkflowRequest;
use App\Domain\Workflows\Resources\WorkflowResource;
use App\Domain\Workflows\Services\WorkflowTemplateService;

class AdminWorkflowController
{
    public function __construct(private readonly WorkflowTemplateService $workflowTemplateService)
    {
    }

    public function index()
    {
        $workflows = Workflow::query()->latest('id')->paginate(50);

        return WorkflowResource::collection($workflows);
    }

    public function show(Workflow $workflow)
    {
        return new WorkflowResource($workflow->load(['steps', 'transitions.fromStep', 'transitions.toStep']));
    }

    public function store(AdminUpsertWorkflowRequest $request)
    {
        $data = $request->validated();

        try {
            $workflow = $this->workflowTemplateService->create([
                'code' => (string) $data['code'],
                'name' => (string) $data['name'],
                'is_active' => isset($data['is_active']) ? (bool) $data['is_active'] : true,
            ]);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new WorkflowResource($workflow);
    }

    public function update(AdminUpsertWorkflowRequest $request, Workflow $workflow)
    {
        $data = $request->validated();

        try {
            $updated = $this->workflowTemplateService->update($workflow, $data);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new WorkflowResource($updated->load(['steps', 'transitions.fromStep', 'transitions.toStep']));
    }
}

