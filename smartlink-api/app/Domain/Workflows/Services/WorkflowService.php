<?php

namespace App\Domain\Workflows\Services;

use App\Domain\Dispatch\Services\DispatchService;
use App\Domain\Orders\Enums\OrderQuoteStatus;
use App\Domain\Orders\Enums\OrderWorkflowState;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderWorkflowEvent;
use App\Domain\Shops\Enums\ShopType;
use App\Domain\Users\Models\User;
use App\Domain\Workflows\Models\Workflow;
use App\Domain\Workflows\Models\WorkflowStep;
use App\Domain\Workflows\Models\WorkflowStepTransition;
use App\Support\Exceptions\ConflictException;
use Illuminate\Support\Facades\DB;

class WorkflowService
{
    public function __construct(private readonly DispatchService $dispatchService)
    {
    }

    public function start(User $seller, Order $order, ?int $etaMin = null, ?int $etaMax = null): Order
    {
        return DB::transaction(function () use ($seller, $order, $etaMin, $etaMax): Order {
            /** @var Order $locked */
            $locked = Order::query()
                ->whereKey($order->id)
                ->lockForUpdate()
                ->firstOrFail();

            $this->assertSellerOwnsOrder($seller, $locked);

            if ($locked->admin_paused_at) {
                throw new ConflictException('Order is paused.');
            }

            if (! $locked->workflow_id) {
                $locked->forceFill([
                    'workflow_id' => $locked->shop?->default_workflow_id,
                ])->save();
            }

            if (! $locked->workflow_id) {
                throw new \RuntimeException('No workflow configured for this shop/order.');
            }

            if ($locked->workflow_step_id) {
                return $locked->fresh(['workflow', 'workflowStep', 'workflowEvents']);
            }

            /** @var WorkflowStep $firstStep */
            $firstStep = WorkflowStep::query()
                ->where('workflow_id', $locked->workflow_id)
                ->orderBy('sequence')
                ->firstOrFail();

            $locked->forceFill([
                'workflow_step_id' => $firstStep->id,
                'workflow_state' => $this->stateFor($locked, $firstStep),
                'workflow_eta_min' => $etaMin,
                'workflow_eta_max' => $etaMax,
                'workflow_started_at' => $locked->workflow_started_at ?? now(),
            ])->save();

            OrderWorkflowEvent::create([
                'order_id' => $locked->id,
                'from_step_id' => null,
                'to_step_id' => $firstStep->id,
                'changed_by_user_id' => $seller->id,
                'created_at' => now(),
            ]);

            if ($firstStep->is_dispatch_trigger) {
                $this->dispatchOrThrow($seller, $locked);
            }

            return $locked->fresh(['workflow', 'workflowStep', 'workflowEvents.toStep', 'workflowEvents.fromStep']);
        });
    }

    public function advance(User $seller, Order $order, string $toStepKey, ?int $etaMin = null, ?int $etaMax = null): Order
    {
        return DB::transaction(function () use ($seller, $order, $toStepKey, $etaMin, $etaMax): Order {
            /** @var Order $locked */
            $locked = Order::query()
                ->whereKey($order->id)
                ->lockForUpdate()
                ->firstOrFail();

            $this->assertSellerOwnsOrder($seller, $locked);

            if ($locked->admin_paused_at) {
                throw new ConflictException('Order is paused.');
            }

            if (! $locked->workflow_id || ! $locked->workflow_step_id) {
                throw new \RuntimeException('Workflow has not been started for this order.');
            }

            /** @var Workflow $workflow */
            $workflow = Workflow::query()->whereKey($locked->workflow_id)->firstOrFail();

            /** @var WorkflowStep $from */
            $from = WorkflowStep::query()->whereKey($locked->workflow_step_id)->firstOrFail();

            /** @var WorkflowStep $to */
            $to = WorkflowStep::query()
                ->where('workflow_id', $workflow->id)
                ->where('step_key', $toStepKey)
                ->firstOrFail();

            $isAllowed = WorkflowStepTransition::query()
                ->where('workflow_id', $workflow->id)
                ->where('from_step_id', $from->id)
                ->where('to_step_id', $to->id)
                ->exists();

            if (! $isAllowed) {
                throw new \RuntimeException('Invalid workflow transition.');
            }

            $this->assertTransitionRules($locked, $to);

            $locked->forceFill([
                'workflow_step_id' => $to->id,
                'workflow_state' => $this->stateFor($locked, $to),
                'workflow_eta_min' => $etaMin ?? $locked->workflow_eta_min,
                'workflow_eta_max' => $etaMax ?? $locked->workflow_eta_max,
                'workflow_completed_at' => $to->is_terminal ? now() : null,
            ])->save();

            OrderWorkflowEvent::create([
                'order_id' => $locked->id,
                'from_step_id' => $from->id,
                'to_step_id' => $to->id,
                'changed_by_user_id' => $seller->id,
                'created_at' => now(),
            ]);

            if ($to->is_dispatch_trigger) {
                $this->dispatchOrThrow($seller, $locked);
            }

            return $locked->fresh(['workflow', 'workflowStep', 'workflowEvents.toStep', 'workflowEvents.fromStep']);
        });
    }

    /**
     * @return list<array{step_key:string, title:string, sequence:int, is_dispatch_trigger:bool, is_terminal:bool}>
     */
    public function nextSteps(User $seller, Order $order): array
    {
        $this->assertSellerOwnsOrder($seller, $order);

        if (! $order->workflow_id || ! $order->workflow_step_id) {
            return [];
        }

        $toStepIds = WorkflowStepTransition::query()
            ->where('workflow_id', $order->workflow_id)
            ->where('from_step_id', $order->workflow_step_id)
            ->pluck('to_step_id')
            ->all();

        if ($toStepIds === []) {
            return [];
        }

        $steps = WorkflowStep::query()
            ->where('workflow_id', $order->workflow_id)
            ->whereIn('id', $toStepIds)
            ->orderBy('sequence')
            ->get();

        return $steps->map(function (WorkflowStep $step) {
            return [
                'step_key' => $step->step_key,
                'title' => $step->title,
                'sequence' => (int) $step->sequence,
                'is_dispatch_trigger' => (bool) $step->is_dispatch_trigger,
                'is_terminal' => (bool) $step->is_terminal,
            ];
        })->values()->all();
    }

    private function assertSellerOwnsOrder(User $seller, Order $order): void
    {
        if ((int) ($order->shop?->seller_user_id ?? 0) !== (int) $seller->id) {
            throw new \RuntimeException('Forbidden.');
        }
    }

    private function assertTransitionRules(Order $order, WorkflowStep $toStep): void
    {
        if ($order->service_type === ShopType::Repair && $toStep->step_key === 'repairing') {
            if ($order->quote_status !== OrderQuoteStatus::Approved) {
                throw new ConflictException('Quote approval required before repairing.');
            }
        }
    }

    private function stateFor(Order $order, WorkflowStep $step): OrderWorkflowState
    {
        if ($step->is_terminal) {
            return OrderWorkflowState::Completed;
        }

        if ($step->is_dispatch_trigger) {
            return OrderWorkflowState::Ready;
        }

        if ($order->service_type === ShopType::Repair && $step->step_key === 'awaiting_approval' && $order->quote_status !== OrderQuoteStatus::Approved) {
            return OrderWorkflowState::Blocked;
        }

        return OrderWorkflowState::InProgress;
    }

    private function dispatchOrThrow(User $seller, Order $order): void
    {
        if ($order->payment_status?->value !== 'paid') {
            throw new ConflictException('Order must be paid before dispatch.');
        }

        $this->dispatchService->dispatchOrder($seller, $order);
    }
}
