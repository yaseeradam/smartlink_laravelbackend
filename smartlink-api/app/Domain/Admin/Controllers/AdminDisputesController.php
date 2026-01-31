<?php

namespace App\Domain\Admin\Controllers;

use App\Domain\Admin\Events\AdminDisputeUpdated;
use App\Domain\Admin\Services\AdminAuditService;
use App\Domain\Disputes\Enums\DisputeResolution;
use App\Domain\Disputes\Enums\DisputeStatus;
use App\Domain\Disputes\Models\Dispute;
use App\Domain\Disputes\Resources\DisputeResource;
use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Products\Services\InventoryService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminDisputesController
{
    public function __construct(
        private readonly AdminAuditService $audit,
        private readonly EscrowService $escrowService,
        private readonly InventoryService $inventoryService,
    ) {
    }

    public function index()
    {
        $disputes = Dispute::query()
            ->latest('id')
            ->paginate(30);

        return DisputeResource::collection($disputes);
    }

    public function show(Dispute $dispute)
    {
        return new DisputeResource($dispute->loadMissing(['order']));
    }

    public function resolve(Request $request, Dispute $dispute)
    {
        $admin = $request->user('admin');
        $data = $request->validate([
            'resolution' => ['required', 'string', 'max:40'],
            'reason' => ['required', 'string', 'min:3'],
        ]);

        $resolutionKey = (string) $data['resolution'];
        $resolution = match ($resolutionKey) {
            'refund_buyer' => DisputeResolution::RefundBuyer,
            'release_to_seller' => DisputeResolution::PaySeller,
            default => null,
        };

        if (! $resolution) {
            return response()->json(['message' => 'Unsupported resolution.'], 422);
        }

        /** @var Dispute $resolved */
        $resolved = DB::transaction(function () use ($request, $dispute, $admin, $resolution, $data) {
            /** @var Dispute $lockedDispute */
            $lockedDispute = Dispute::query()->whereKey($dispute->id)->lockForUpdate()->firstOrFail();

            /** @var Order $lockedOrder */
            $lockedOrder = Order::query()->with(['escrowHold'])->whereKey($lockedDispute->order_id)->lockForUpdate()->firstOrFail();

            $hold = $lockedOrder->escrowHold()?->lockForUpdate()->first();

            $old = [
                'dispute' => $lockedDispute->toArray(),
                'order' => $lockedOrder->toArray(),
                'escrow' => $hold?->toArray(),
            ];

            if ($lockedDispute->status === DisputeStatus::Resolved) {
                return $lockedDispute->fresh();
            }

            if ($resolution === DisputeResolution::PaySeller) {
                if ($hold && $hold->status === EscrowStatus::Held) {
                    $this->escrowService->release($hold, null);
                }

                $lockedOrder->forceFill(['status' => OrderStatus::Confirmed])->save();
                OrderStatusHistory::create([
                    'order_id' => $lockedOrder->id,
                    'status' => OrderStatus::Confirmed->value,
                    'changed_by_user_id' => null,
                ]);
            }

            if ($resolution === DisputeResolution::RefundBuyer) {
                if ($hold && in_array($hold->status, [EscrowStatus::Held, EscrowStatus::Frozen], true)) {
                    $this->escrowService->refund($hold, null);
                }

                $lockedOrder->forceFill([
                    'status' => OrderStatus::Cancelled,
                    'payment_status' => OrderPaymentStatus::Refunded,
                ])->save();

                OrderStatusHistory::create([
                    'order_id' => $lockedOrder->id,
                    'status' => OrderStatus::Cancelled->value,
                    'changed_by_user_id' => null,
                ]);

                $this->inventoryService->restoreOrderStock($lockedOrder);
            }

            $lockedDispute->forceFill([
                'status' => DisputeStatus::Resolved,
                'resolution' => $resolution,
                'resolved_by_admin_id' => null,
            ])->save();

            $new = [
                'dispute' => $lockedDispute->fresh()->toArray(),
                'order' => $lockedOrder->fresh()->toArray(),
                'escrow' => $hold?->fresh()?->toArray(),
            ];

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'dispute.resolve',
                entityType: 'dispute',
                entityId: (int) $lockedDispute->id,
                reason: (string) $data['reason'],
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $lockedDispute->fresh();
        });

        event(new AdminDisputeUpdated($resolved->order_id, [
            'order_id' => $resolved->order_id,
            'dispute_id' => $resolved->id,
            'status' => $resolved->status->value,
            'resolution' => $resolved->resolution?->value,
        ]));

        return new DisputeResource($resolved);
    }
}

