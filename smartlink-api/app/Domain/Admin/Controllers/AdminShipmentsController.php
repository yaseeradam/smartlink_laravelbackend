<?php

namespace App\Domain\Admin\Controllers;

use App\Domain\Admin\Events\AdminShipmentUpdated;
use App\Domain\Admin\Services\AdminAuditService;
use App\Domain\Escrow\Jobs\AutoReleaseEscrowJob;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Shipping\Enums\ShipmentStatus;
use App\Domain\Shipping\Models\Shipment;
use App\Domain\Shipping\Models\ShipmentStatusHistory;
use App\Domain\Shipping\Resources\ShipmentResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminShipmentsController
{
    public function __construct(private readonly AdminAuditService $audit)
    {
    }

    public function index()
    {
        $shipments = Shipment::query()
            ->latest('id')
            ->paginate(30);

        return ShipmentResource::collection($shipments);
    }

    public function show(Shipment $shipment)
    {
        return new ShipmentResource($shipment->loadMissing(['timeline']));
    }

    public function invalidateTracking(Request $request, Shipment $shipment)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $result = DB::transaction(function () use ($shipment, $admin, $reason, $request) {
            /** @var Shipment $lockedShipment */
            $lockedShipment = Shipment::query()->whereKey($shipment->id)->lockForUpdate()->firstOrFail();

            if (in_array($lockedShipment->status, [ShipmentStatus::Delivered, ShipmentStatus::Confirmed], true)) {
                return response()->json(['message' => 'Cannot invalidate tracking after delivery.'], 409);
            }

            $old = $lockedShipment->loadMissing(['timeline'])->toArray();

            $lockedShipment->forceFill([
                'tracking_number' => null,
                'proof_dropoff_url' => null,
            ])->save();

            if (in_array($lockedShipment->status, [ShipmentStatus::DroppedOff, ShipmentStatus::InTransit, ShipmentStatus::OutForDelivery], true)) {
                $lockedShipment->forceFill(['status' => ShipmentStatus::Packed])->save();
                $this->appendTimeline($lockedShipment, ShipmentStatus::Packed, meta: ['admin_action' => 'shipment.invalidate_tracking']);
            }

            $new = $lockedShipment->fresh()->loadMissing(['timeline'])->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'shipment.invalidate_tracking',
                entityType: 'shipment',
                entityId: (int) $lockedShipment->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $lockedShipment->fresh(['timeline']);
        });

        if ($result instanceof \Illuminate\Http\JsonResponse) {
            return $result;
        }

        event(new AdminShipmentUpdated($result->order_id, [
            'order_id' => $result->order_id,
            'shipment_id' => $result->id,
            'status' => $result->status->value,
            'tracking_number' => $result->tracking_number,
        ]));

        return new ShipmentResource($result);
    }

    public function markStatus(Request $request, Shipment $shipment)
    {
        $admin = $request->user('admin');
        $data = $request->validate([
            'status' => ['required', 'string', 'max:32'],
            'reason' => ['required', 'string', 'min:3'],
        ]);

        $status = ShipmentStatus::tryFrom((string) $data['status']);
        if (! $status || $status === ShipmentStatus::Confirmed) {
            return response()->json(['message' => 'Invalid status.'], 422);
        }

        $result = $this->setShipmentStatus(
            request: $request,
            shipment: $shipment,
            status: $status,
            adminUserId: (int) $admin->id,
            reason: (string) $data['reason'],
            actionType: 'shipment.mark_status',
        );

        if ($result instanceof \Illuminate\Http\JsonResponse) {
            return $result;
        }

        return new ShipmentResource($result);
    }

    public function forceDelivered(Request $request, Shipment $shipment)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $result = $this->setShipmentStatus(
            request: $request,
            shipment: $shipment,
            status: ShipmentStatus::Delivered,
            adminUserId: (int) $admin->id,
            reason: $reason,
            actionType: 'shipment.force_delivered',
        );

        if ($result instanceof \Illuminate\Http\JsonResponse) {
            return $result;
        }

        return new ShipmentResource($result);
    }

    public function forceFailed(Request $request, Shipment $shipment)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $result = $this->setShipmentStatus(
            request: $request,
            shipment: $shipment,
            status: ShipmentStatus::Failed,
            adminUserId: (int) $admin->id,
            reason: $reason,
            actionType: 'shipment.force_failed',
        );

        if ($result instanceof \Illuminate\Http\JsonResponse) {
            return $result;
        }

        return new ShipmentResource($result);
    }

    private function setShipmentStatus(
        Request $request,
        Shipment $shipment,
        ShipmentStatus $status,
        int $adminUserId,
        string $reason,
        string $actionType,
    ) {
        $result = DB::transaction(function () use ($request, $shipment, $status, $adminUserId, $reason, $actionType) {
            /** @var Shipment $lockedShipment */
            $lockedShipment = Shipment::query()->whereKey($shipment->id)->lockForUpdate()->firstOrFail();
            /** @var Order $lockedOrder */
            $lockedOrder = Order::query()->with(['escrowHold'])->whereKey($lockedShipment->order_id)->lockForUpdate()->firstOrFail();

            $old = [
                'shipment' => $lockedShipment->loadMissing(['timeline'])->toArray(),
                'order' => $lockedOrder->toArray(),
                'escrow' => $lockedOrder->escrowHold?->toArray(),
            ];

            if ($lockedShipment->status === ShipmentStatus::Confirmed) {
                return response()->json(['message' => 'Shipment already confirmed.'], 409);
            }

            if ($lockedShipment->status !== $status) {
                $lockedShipment->forceFill(['status' => $status])->save();
                $this->appendTimeline($lockedShipment, $status, meta: ['admin_action' => $actionType]);
            }

            if ($status === ShipmentStatus::Delivered) {
                if (! in_array($lockedOrder->status, [OrderStatus::Delivered, OrderStatus::Confirmed], true)) {
                    $lockedOrder->forceFill(['status' => OrderStatus::Delivered])->save();
                    OrderStatusHistory::create([
                        'order_id' => $lockedOrder->id,
                        'status' => OrderStatus::Delivered->value,
                        'changed_by_user_id' => null,
                    ]);
                }

                $hold = $lockedOrder->escrowHold;
                if ($hold && ! $hold->hold_expires_at) {
                    $hours = (int) config('smartlink.shipping.auto_release_hours', 72);
                    $hours = max(1, $hours);
                    $expiresAt = now()->addHours($hours);
                    $hold->forceFill(['hold_expires_at' => $expiresAt])->save();
                    dispatch((new AutoReleaseEscrowJob($hold->id))->delay($expiresAt)->afterCommit());
                }
            }

            $new = [
                'shipment' => $lockedShipment->fresh()->loadMissing(['timeline'])->toArray(),
                'order' => $lockedOrder->fresh()->toArray(),
                'escrow' => $lockedOrder->escrowHold?->fresh()?->toArray(),
            ];

            $this->audit->log(
                adminUserId: $adminUserId,
                actionType: $actionType,
                entityType: 'shipment',
                entityId: (int) $lockedShipment->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $lockedShipment->fresh(['timeline']);
        });

        if ($result instanceof \Illuminate\Http\JsonResponse) {
            return $result;
        }

        event(new AdminShipmentUpdated($result->order_id, [
            'order_id' => $result->order_id,
            'shipment_id' => $result->id,
            'status' => $result->status->value,
        ]));

        return $result;
    }

    /**
     * @param  array<string,mixed>|null  $meta
     */
    private function appendTimeline(Shipment $shipment, ShipmentStatus $status, ?array $meta): void
    {
        ShipmentStatusHistory::create([
            'shipment_id' => $shipment->id,
            'status' => $status->value,
            'changed_by_user_id' => null,
            'meta_json' => $meta,
        ]);
    }
}

