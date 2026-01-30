<?php

namespace App\Domain\Orders\Controllers;

use App\Domain\Orders\Events\OrderWorkflowUpdated;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Requests\AdvanceOrderWorkflowRequest;
use App\Domain\Orders\Requests\StartOrderWorkflowRequest;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Workflows\Services\WorkflowService;
use App\Support\Exceptions\ConflictException;
use Illuminate\Support\Facades\Gate;

class SellerOrderWorkflowController
{
    public function __construct(private readonly WorkflowService $workflowService)
    {
    }

    public function start(StartOrderWorkflowRequest $request, Order $order)
    {
        Gate::authorize('manageWorkflow', $order);

        $data = $request->validated();

        try {
            $updated = $this->workflowService->start(
                $request->user(),
                $order,
                isset($data['eta_min']) ? (int) $data['eta_min'] : null,
                isset($data['eta_max']) ? (int) $data['eta_max'] : null,
            );
        } catch (ConflictException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        } catch (\RuntimeException | \InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->broadcastWorkflow($updated);

        return new OrderResource($updated->load(['workflow', 'workflowStep', 'workflowEvents.toStep', 'workflowEvents.fromStep']));
    }

    public function advance(AdvanceOrderWorkflowRequest $request, Order $order)
    {
        Gate::authorize('manageWorkflow', $order);

        $data = $request->validated();

        try {
            $updated = $this->workflowService->advance(
                $request->user(),
                $order,
                (string) $data['to_step_key'],
                isset($data['eta_min']) ? (int) $data['eta_min'] : null,
                isset($data['eta_max']) ? (int) $data['eta_max'] : null,
            );
        } catch (ConflictException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        } catch (\RuntimeException | \InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->broadcastWorkflow($updated);

        return new OrderResource($updated->load(['workflow', 'workflowStep', 'workflowEvents.toStep', 'workflowEvents.fromStep']));
    }

    public function nextSteps(Order $order)
    {
        Gate::authorize('manageWorkflow', $order);

        try {
            $steps = $this->workflowService->nextSteps(request()->user(), $order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json(['data' => $steps]);
    }

    private function broadcastWorkflow(Order $order): void
    {
        $order->loadMissing(['workflow', 'workflowStep', 'workflowEvents']);

        $lastChangedAt = collect([
            $order->workflowEvents->last()?->created_at,
            $order->quote_sent_at,
            $order->quote_approved_at,
            $order->updated_at,
        ])->filter()->max()?->toISOString();

        event(new OrderWorkflowUpdated($order->id, [
            'workflow_code' => $order->workflow?->code,
            'current_step_key' => $order->workflowStep?->step_key,
            'current_step_title' => $order->workflowStep?->title,
            'eta_min' => $order->workflow_eta_min,
            'eta_max' => $order->workflow_eta_max,
            'last_changed_at' => $lastChangedAt,
        ]));
    }
}
