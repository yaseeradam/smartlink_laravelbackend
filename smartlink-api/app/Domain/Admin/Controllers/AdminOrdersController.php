<?php

namespace App\Domain\Admin\Controllers;

use App\Domain\Admin\Events\AdminOrderUpdated;
use App\Domain\Admin\Services\AdminAuditService;
use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Orders\Models\OrderWorkflowEvent;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Products\Services\InventoryService;
use App\Domain\Workflows\Models\WorkflowStep;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminOrdersController
{
    public function __construct(
        private readonly AdminAuditService $audit,
        private readonly EscrowService $escrowService,
        private readonly InventoryService $inventoryService,
    ) {
    }

    public function index()
    {
        $orders = Order::query()
            ->latest('id')
            ->paginate(30);

        return OrderResource::collection($orders);
    }

    public function show(Order $order)
    {
        return new OrderResource($order->loadMissing([
            'items',
            'escrowHold',
            'dispatchJob',
            'shipment.timeline',
            'workflow',
            'workflowStep',
            'workflowEvents.toStep',
            'workflowEvents.fromStep',
        ]));
    }

    public function pause(Request $request, Order $order)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $updated = DB::transaction(function () use ($order, $admin, $reason, $request) {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();
            $locked->forceFill(['admin_paused_at' => $locked->admin_paused_at ?? now()])->save();
            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'order.pause',
                entityType: 'order',
                entityId: (int) $locked->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $locked->fresh();
        });

        event(new AdminOrderUpdated($updated->id, [
            'order_id' => $updated->id,
            'status' => $updated->status->value,
            'admin_paused_at' => optional($updated->admin_paused_at)?->toISOString(),
        ]));

        return new OrderResource($updated);
    }

    public function resume(Request $request, Order $order)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $updated = DB::transaction(function () use ($order, $admin, $reason, $request) {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();
            $locked->forceFill(['admin_paused_at' => null])->save();
            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'order.resume',
                entityType: 'order',
                entityId: (int) $locked->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $locked->fresh();
        });

        event(new AdminOrderUpdated($updated->id, [
            'order_id' => $updated->id,
            'status' => $updated->status->value,
            'admin_paused_at' => optional($updated->admin_paused_at)?->toISOString(),
        ]));

        return new OrderResource($updated);
    }

    public function overrideWorkflowStep(Request $request, Order $order)
    {
        $admin = $request->user('admin');
        $data = $request->validate([
            'to_step_key' => ['required', 'string', 'max:80'],
            'reason' => ['required', 'string', 'min:3'],
        ]);

        $updated = DB::transaction(function () use ($order, $admin, $data, $request) {
            /** @var Order $locked */
            $locked = Order::query()->with(['shop'])->whereKey($order->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();

            if (! $locked->workflow_id) {
                $locked->forceFill(['workflow_id' => $locked->shop?->default_workflow_id])->save();
            }
            if (! $locked->workflow_id) {
                throw new \RuntimeException('No workflow configured for this order.');
            }

            $to = WorkflowStep::query()
                ->where('workflow_id', $locked->workflow_id)
                ->where('step_key', (string) $data['to_step_key'])
                ->firstOrFail();

            $fromStepId = $locked->workflow_step_id;

            $locked->forceFill([
                'workflow_step_id' => $to->id,
                'workflow_state' => $to->is_terminal ? 'completed' : ($to->is_dispatch_trigger ? 'ready' : 'in_progress'),
                'workflow_completed_at' => $to->is_terminal ? now() : null,
            ])->save();

            OrderWorkflowEvent::create([
                'order_id' => $locked->id,
                'from_step_id' => $fromStepId,
                'to_step_id' => $to->id,
                'changed_by_user_id' => null,
                'created_at' => now(),
            ]);

            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'order.override_workflow_step',
                entityType: 'order',
                entityId: (int) $locked->id,
                reason: (string) $data['reason'],
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $locked->fresh(['workflow', 'workflowStep', 'workflowEvents.toStep', 'workflowEvents.fromStep']);
        });

        event(new AdminOrderUpdated($updated->id, [
            'order_id' => $updated->id,
            'workflow_step_key' => $updated->workflowStep?->step_key,
            'workflow_state' => $updated->workflow_state?->value,
        ]));

        return new OrderResource($updated);
    }

    public function forceComplete(Request $request, Order $order)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $updated = DB::transaction(function () use ($order, $admin, $reason, $request) {
            /** @var Order $locked */
            $locked = Order::query()->with(['escrowHold', 'dispatchJob'])->whereKey($order->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();

            if ($locked->status !== OrderStatus::Confirmed) {
                $locked->forceFill(['status' => OrderStatus::Confirmed])->save();
                OrderStatusHistory::create([
                    'order_id' => $locked->id,
                    'status' => OrderStatus::Confirmed->value,
                    'changed_by_user_id' => null,
                ]);
            }

            $hold = $locked->escrowHold;
            if ($hold && in_array($hold->status, [EscrowStatus::Held, EscrowStatus::Frozen], true)) {
                $this->escrowService->release($hold, null);
            }

            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'order.force_complete',
                entityType: 'order',
                entityId: (int) $locked->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $locked->fresh(['escrowHold', 'dispatchJob']);
        });

        event(new AdminOrderUpdated($updated->id, [
            'order_id' => $updated->id,
            'status' => $updated->status->value,
        ]));

        return new OrderResource($updated);
    }

    public function cancel(Request $request, Order $order)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $updated = DB::transaction(function () use ($order, $admin, $reason, $request) {
            /** @var Order $locked */
            $locked = Order::query()->with(['escrowHold'])->whereKey($order->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();

            $hold = $locked->escrowHold()->lockForUpdate()->first();
            if ($hold && in_array($hold->status, [EscrowStatus::Held, EscrowStatus::Frozen], true)) {
                $this->escrowService->refund($hold, null);
            }

            $locked->forceFill([
                'status' => OrderStatus::Cancelled,
                'payment_status' => OrderPaymentStatus::Refunded,
            ])->save();

            OrderStatusHistory::create([
                'order_id' => $locked->id,
                'status' => OrderStatus::Cancelled->value,
                'changed_by_user_id' => null,
            ]);

            $this->inventoryService->restoreOrderStock($locked);

            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'order.cancel',
                entityType: 'order',
                entityId: (int) $locked->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $locked->fresh(['escrowHold']);
        });

        event(new AdminOrderUpdated($updated->id, [
            'order_id' => $updated->id,
            'status' => $updated->status->value,
        ]));

        return new OrderResource($updated);
    }

    public function forceReleaseEscrow(Request $request, Order $order)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        DB::transaction(function () use ($order, $admin, $reason, $request) {
            /** @var Order $locked */
            $locked = Order::query()->with(['escrowHold'])->whereKey($order->id)->lockForUpdate()->firstOrFail();
            $hold = $locked->escrowHold()->lockForUpdate()->firstOrFail();

            $old = $hold->toArray();
            $this->escrowService->release($hold, null);
            $new = $hold->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'escrow.force_release',
                entityType: 'order',
                entityId: (int) $locked->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );
        });

        event(new AdminOrderUpdated($order->id, [
            'order_id' => $order->id,
            'action' => 'escrow.force_release',
        ]));

        return response()->json(['message' => 'Escrow released.']);
    }

    public function forceRefund(Request $request, Order $order)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        DB::transaction(function () use ($order, $admin, $reason, $request) {
            /** @var Order $locked */
            $locked = Order::query()->with(['escrowHold'])->whereKey($order->id)->lockForUpdate()->firstOrFail();
            $hold = $locked->escrowHold()->lockForUpdate()->firstOrFail();

            $old = $hold->toArray();
            $this->escrowService->refund($hold, null);
            $new = $hold->fresh()->toArray();

            $locked->forceFill(['payment_status' => OrderPaymentStatus::Refunded])->save();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'escrow.force_refund',
                entityType: 'order',
                entityId: (int) $locked->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );
        });

        event(new AdminOrderUpdated($order->id, [
            'order_id' => $order->id,
            'action' => 'escrow.force_refund',
        ]));

        return response()->json(['message' => 'Escrow refunded.']);
    }

    public function holdFunds(Request $request, Order $order)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        DB::transaction(function () use ($order, $admin, $reason, $request) {
            $hold = $order->escrowHold()->lockForUpdate()->firstOrFail();
            $old = $hold->toArray();
            $this->escrowService->freeze($hold);
            $new = $hold->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'escrow.hold_funds',
                entityType: 'order',
                entityId: (int) $order->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );
        });

        event(new AdminOrderUpdated($order->id, [
            'order_id' => $order->id,
            'action' => 'escrow.hold_funds',
        ]));

        return response()->json(['message' => 'Funds held.']);
    }

    public function unholdFunds(Request $request, Order $order)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        DB::transaction(function () use ($order, $admin, $reason, $request) {
            $hold = $order->escrowHold()->lockForUpdate()->firstOrFail();
            $old = $hold->toArray();
            $this->escrowService->unfreeze($hold);
            $new = $hold->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'escrow.unhold_funds',
                entityType: 'order',
                entityId: (int) $order->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );
        });

        event(new AdminOrderUpdated($order->id, [
            'order_id' => $order->id,
            'action' => 'escrow.unhold_funds',
        ]));

        return response()->json(['message' => 'Funds unheld.']);
    }
}

