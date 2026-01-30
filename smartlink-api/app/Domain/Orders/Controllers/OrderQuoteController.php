<?php

namespace App\Domain\Orders\Controllers;

use App\Domain\Orders\Events\OrderWorkflowUpdated;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Requests\SendOrderQuoteRequest;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Orders\Services\OrderQuoteService;
use App\Support\Exceptions\ConflictException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class OrderQuoteController
{
    public function __construct(private readonly OrderQuoteService $quoteService)
    {
    }

    public function send(SendOrderQuoteRequest $request, Order $order)
    {
        Gate::authorize('sendQuote', $order);

        $data = $request->validated();

        try {
            $updated = $this->quoteService->send(
                $request->user(),
                $order,
                (float) $data['quoted_amount'],
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

    public function approve(Request $request, Order $order)
    {
        Gate::authorize('approveQuote', $order);

        try {
            $updated = $this->quoteService->approve($request->user(), $order);
        } catch (ConflictException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        } catch (\RuntimeException | \InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->broadcastWorkflow($updated);

        return new OrderResource($updated->load(['workflow', 'workflowStep', 'workflowEvents.toStep', 'workflowEvents.fromStep', 'escrowHold']));
    }

    public function reject(Request $request, Order $order)
    {
        Gate::authorize('approveQuote', $order);

        try {
            $updated = $this->quoteService->reject($request->user(), $order);
        } catch (ConflictException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        } catch (\RuntimeException | \InvalidArgumentException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $this->broadcastWorkflow($updated);

        return new OrderResource($updated->load(['workflow', 'workflowStep', 'workflowEvents.toStep', 'workflowEvents.fromStep']));
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
