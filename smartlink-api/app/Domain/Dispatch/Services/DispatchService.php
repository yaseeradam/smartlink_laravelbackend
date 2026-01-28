<?php

namespace App\Domain\Dispatch\Services;

use App\Domain\Dispatch\Enums\DispatchJobStatus;
use App\Domain\Dispatch\Enums\DispatchOfferStatus;
use App\Domain\Dispatch\Enums\DispatchPurpose;
use App\Domain\Dispatch\Jobs\BroadcastDispatchOffersJob;
use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Dispatch\Models\DispatchOffer;
use App\Domain\Dispatch\Models\SellerRiderPool;
use App\Domain\Escrow\Jobs\AutoReleaseEscrowJob;
use App\Domain\Evidence\Enums\EvidenceType;
use App\Domain\Evidence\Models\OrderEvidence;
use App\Domain\Notifications\Jobs\SendPushNotificationJob;
use App\Domain\Notifications\Services\NotificationService;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Riders\Enums\RiderAvailabilityStatus;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Riders\Services\RiderStatsService;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class DispatchService
{
    public function __construct(
        private readonly RiderStatsService $riderStatsService,
        private readonly NotificationService $notificationService,
    ) {
    }

    public function dispatchOrder(User $seller, Order $order, DispatchPurpose $purpose = DispatchPurpose::Delivery): DispatchJob
    {
        return DB::transaction(function () use ($seller, $order, $purpose): DispatchJob {
            /** @var Order $lockedOrder */
            $lockedOrder = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ((int) $lockedOrder->shop_id !== (int) ($seller->shop?->id ?? 0)) {
                throw new \RuntimeException('Forbidden.');
            }

            if (! in_array($lockedOrder->status, [OrderStatus::Paid, OrderStatus::AcceptedBySeller], true)) {
                throw new \RuntimeException('Order is not dispatchable.');
            }

            if ($lockedOrder->status === OrderStatus::Paid) {
                $lockedOrder->forceFill(['status' => OrderStatus::AcceptedBySeller])->save();
                $this->appendHistory($lockedOrder, OrderStatus::AcceptedBySeller, $seller->id);
            }

            $lockedOrder->forceFill(['status' => OrderStatus::Dispatching])->save();
            $this->appendHistory($lockedOrder, OrderStatus::Dispatching, $seller->id);

            $minutes = (int) config('smartlink.dispatch.private_pool_minutes', 10);
            $now = now();

            $job = DispatchJob::firstOrCreate(
                ['order_id' => $lockedOrder->id, 'purpose' => $purpose],
                [
                    'shop_id' => $lockedOrder->shop_id,
                    'zone_id' => $lockedOrder->zone_id,
                    'status' => DispatchJobStatus::Broadcasting,
                    'assigned_rider_user_id' => null,
                    'private_pool_only_until' => $now->copy()->addMinutes($minutes),
                    'fallback_broadcast_at' => $now->copy()->addMinutes($minutes),
                ],
            );

            // Broadcast to private pool immediately.
            dispatch(new BroadcastDispatchOffersJob($job->id, 'private'));

            // Fallback broadcast after window.
            dispatch((new BroadcastDispatchOffersJob($job->id, 'fallback'))->delay($now->copy()->addMinutes($minutes)));

            return $job->fresh();
        });
    }

    public function broadcastOffers(int $dispatchJobId, string $mode): void
    {
        /** @var DispatchJob $job */
        $job = DispatchJob::query()->with(['order'])->findOrFail($dispatchJobId);

        if ($job->status === DispatchJobStatus::Assigned) {
            return;
        }

        if ($mode === 'private') {
            $riderIds = SellerRiderPool::query()
                ->where('shop_id', $job->shop_id)
                ->where('status', 'active')
                ->pluck('rider_user_id')
                ->all();
        } elseif ($mode === 'fallback') {
            $riderIds = $this->getAvailableRidersInZone($job->zone_id);
        } else {
            throw new \InvalidArgumentException('Invalid broadcast mode.');
        }

        if ($riderIds === []) {
            return;
        }

        $availableRiderIds = $this->filterAvailableRiders($riderIds, $job->zone_id);

        foreach ($availableRiderIds as $riderId) {
            try {
                $offer = DispatchOffer::create([
                    'dispatch_job_id' => $job->id,
                    'rider_user_id' => $riderId,
                    'offer_status' => DispatchOfferStatus::Sent,
                    'offered_at' => now(),
                    'responded_at' => null,
                ]);
                dispatch(new SendPushNotificationJob(
                    (int) $riderId,
                    'New dispatch offer',
                    'A new delivery request is available.',
                    [
                        'dispatch_job_id' => $job->id,
                        'order_id' => $job->order_id,
                        'purpose' => $job->purpose->value,
                        'offer_id' => $offer->id,
                    ],
                ));
            } catch (QueryException $e) {
                // Ignore duplicates (idempotent broadcast).
            }
        }
    }

    public function offersForRider(User $rider)
    {
        return DispatchOffer::query()
            ->with(['job.order.items', 'job.order.escrowHold'])
            ->where('rider_user_id', $rider->id)
            ->whereIn('offer_status', [DispatchOfferStatus::Sent, DispatchOfferStatus::Seen])
            ->orderByDesc('id')
            ->paginate(20);
    }

    public function acceptOffer(User $rider, int $offerId): DispatchJob
    {
        return DB::transaction(function () use ($rider, $offerId): DispatchJob {
            /** @var DispatchOffer $offer */
            $offer = DispatchOffer::query()->whereKey($offerId)->lockForUpdate()->firstOrFail();

            if ((int) $offer->rider_user_id !== (int) $rider->id) {
                throw new \RuntimeException('Forbidden.');
            }

            if (! in_array($offer->offer_status, [DispatchOfferStatus::Sent, DispatchOfferStatus::Seen], true)) {
                throw new \RuntimeException('Offer is not acceptible.');
            }

            /** @var DispatchJob $job */
            $job = DispatchJob::query()->whereKey($offer->dispatch_job_id)->lockForUpdate()->firstOrFail();

            if ($job->status === DispatchJobStatus::Assigned) {
                throw new \RuntimeException('Dispatch job already assigned.');
            }

            $job->forceFill([
                'status' => DispatchJobStatus::Assigned,
                'assigned_rider_user_id' => $rider->id,
            ])->save();

            $offer->forceFill([
                'offer_status' => DispatchOfferStatus::Accepted,
                'responded_at' => now(),
            ])->save();

            DispatchOffer::query()
                ->where('dispatch_job_id', $job->id)
                ->where('id', '!=', $offer->id)
                ->whereIn('offer_status', [DispatchOfferStatus::Sent, DispatchOfferStatus::Seen])
                ->update(['offer_status' => DispatchOfferStatus::Expired->value]);

            /** @var Order $order */
            $order = Order::query()->whereKey($job->order_id)->lockForUpdate()->firstOrFail();
            if ($job->purpose === DispatchPurpose::Delivery) {
                $order->forceFill(['status' => OrderStatus::AssignedToRider])->save();
                $this->appendHistory($order, OrderStatus::AssignedToRider, $rider->id);
            }

            RiderAvailability::query()
                ->where('rider_user_id', $rider->id)
                ->update(['status' => RiderAvailabilityStatus::Busy->value, 'last_seen_at' => now()]);

            $this->riderStatsService->refresh($rider->id);

            $buyerId = (int) $order->buyer_user_id;
            $sellerId = (int) ($order->shop?->seller_user_id ?? 0);

            if ($buyerId > 0) {
                dispatch(new SendPushNotificationJob(
                    $buyerId,
                    'Rider assigned',
                    'A rider has been assigned to your order.',
                    ['order_id' => $order->id, 'dispatch_job_id' => $job->id, 'purpose' => $job->purpose->value],
                ));
            }

            if ($sellerId > 0) {
                dispatch(new SendPushNotificationJob(
                    $sellerId,
                    'Rider assigned',
                    'A rider has been assigned to an order.',
                    ['order_id' => $order->id, 'dispatch_job_id' => $job->id, 'purpose' => $job->purpose->value],
                ));
            }

            return $job->fresh();
        });
    }

    public function declineOffer(User $rider, int $offerId): DispatchOffer
    {
        return DB::transaction(function () use ($rider, $offerId) {
            /** @var DispatchOffer $offer */
            $offer = DispatchOffer::query()->whereKey($offerId)->lockForUpdate()->firstOrFail();

            if ((int) $offer->rider_user_id !== (int) $rider->id) {
                throw new \RuntimeException('Forbidden.');
            }

            if (! in_array($offer->offer_status, [DispatchOfferStatus::Sent, DispatchOfferStatus::Seen], true)) {
                return $offer;
            }

            $offer->forceFill([
                'offer_status' => DispatchOfferStatus::Declined,
                'responded_at' => now(),
            ])->save();

            return $offer->fresh();
        });
    }

    public function uploadPickupProof(User $rider, Order $order, string $fileUrl): OrderEvidence
    {
        $this->assertAssignedRider($rider, $order);

        return OrderEvidence::create([
            'order_id' => $order->id,
            'type' => EvidenceType::PickupVideo,
            'file_url' => $fileUrl,
            'captured_by_user_id' => $rider->id,
        ]);
    }

    public function uploadDeliveryProof(User $rider, Order $order, string $fileUrl): OrderEvidence
    {
        $this->assertAssignedRider($rider, $order);

        return OrderEvidence::create([
            'order_id' => $order->id,
            'type' => EvidenceType::DeliveryPhoto,
            'file_url' => $fileUrl,
            'captured_by_user_id' => $rider->id,
        ]);
    }

    public function markPickedUp(User $rider, Order $order): Order
    {
        $this->assertAssignedRider($rider, $order);

        return DB::transaction(function () use ($rider, $order) {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === OrderStatus::PickedUp) {
                return $locked;
            }

            if ($locked->status !== OrderStatus::AssignedToRider) {
                throw new \RuntimeException('Order is not ready for pickup.');
            }

            $hasProof = OrderEvidence::query()
                ->where('order_id', $locked->id)
                ->where('type', EvidenceType::PickupVideo)
                ->where('captured_by_user_id', $rider->id)
                ->exists();

            if (! $hasProof) {
                throw new \RuntimeException('Pickup proof is required.');
            }

            $locked->forceFill(['status' => OrderStatus::PickedUp])->save();
            $this->appendHistory($locked, OrderStatus::PickedUp, $rider->id);

            if ($locked->delivery_otp_required && ! $locked->delivery_otp_hash) {
                $ttlMinutes = (int) config('smartlink.delivery.otp_ttl_minutes', 30);
                $code = (string) random_int(100000, 999999);

                $locked->forceFill([
                    'delivery_otp_hash' => Hash::make($code),
                    'delivery_otp_expires_at' => now()->addMinutes($ttlMinutes),
                ])->save();

                $buyer = $locked->buyer()->first();
                if ($buyer) {
                    $this->notificationService->sendDeliveryOtp((string) $buyer->phone, $code, $ttlMinutes);
                    dispatch(new SendPushNotificationJob(
                        (int) $buyer->id,
                        'Delivery OTP',
                        'Your rider needs the OTP to complete delivery.',
                        ['order_id' => $locked->id],
                        true,
                    ));
                }
            }

            return $locked->fresh();
        });
    }

    public function markDelivered(User $rider, Order $order, ?Carbon $holdExpiresAt = null, ?string $deliveryOtp = null): Order
    {
        $this->assertAssignedRider($rider, $order);

        return DB::transaction(function () use ($rider, $order, $holdExpiresAt, $deliveryOtp) {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === OrderStatus::Delivered) {
                return $locked->fresh(['escrowHold']);
            }

            if ($locked->status !== OrderStatus::PickedUp) {
                throw new \RuntimeException('Order is not picked up.');
            }

            if ($locked->delivery_otp_required) {
                $otp = (string) ($deliveryOtp ?? '');
                if ($otp === '' || ! $locked->delivery_otp_hash || ! Hash::check($otp, $locked->delivery_otp_hash)) {
                    throw new \RuntimeException('Invalid delivery OTP.');
                }

                if ($locked->delivery_otp_expires_at && now()->greaterThan($locked->delivery_otp_expires_at)) {
                    throw new \RuntimeException('Delivery OTP has expired.');
                }

                $locked->forceFill(['delivery_otp_verified_at' => now()])->save();
            }

            $locked->forceFill(['status' => OrderStatus::Delivered])->save();
            $this->appendHistory($locked, OrderStatus::Delivered, $rider->id);

            $hold = $locked->escrowHold()->lockForUpdate()->firstOrFail();
            if (! $hold->hold_expires_at) {
                $expiresAt = $holdExpiresAt ?: now()->addHours((int) config('smartlink.escrow.auto_release_hours', 24));
                $hold->forceFill(['hold_expires_at' => $expiresAt])->save();
                dispatch((new AutoReleaseEscrowJob($hold->id))->delay($expiresAt)->afterCommit());
            }

            RiderAvailability::query()
                ->where('rider_user_id', $rider->id)
                ->update(['status' => RiderAvailabilityStatus::Available->value, 'last_seen_at' => now()]);

            dispatch(new SendPushNotificationJob(
                (int) $locked->buyer_user_id,
                'Order delivered',
                'Your order has been marked as delivered.',
                ['order_id' => $locked->id],
            ));

            if ($locked->shop && $locked->shop->seller_user_id) {
                dispatch(new SendPushNotificationJob(
                    (int) $locked->shop->seller_user_id,
                    'Order delivered',
                    'An order has been delivered.',
                    ['order_id' => $locked->id],
                ));
            }

            $this->riderStatsService->refresh($rider->id);

            return $locked->fresh(['escrowHold']);
        });
    }

    private function assertAssignedRider(User $rider, Order $order): void
    {
        $job = DispatchJob::query()
            ->where('order_id', $order->id)
            ->where('purpose', DispatchPurpose::Delivery->value)
            ->first();

        if (! $job || (int) $job->assigned_rider_user_id !== (int) $rider->id) {
            throw new \RuntimeException('Forbidden.');
        }
    }

    /**
     * @param  list<int>  $riderIds
     * @return list<int>
     */
    private function filterAvailableRiders(array $riderIds, int $zoneId): array
    {
        $ridersInZone = UserZone::query()
            ->whereIn('user_id', $riderIds)
            ->where('type', 'operational')
            ->where('zone_id', $zoneId)
            ->pluck('user_id')
            ->all();

        return RiderAvailability::query()
            ->whereIn('rider_user_id', $ridersInZone)
            ->where('status', RiderAvailabilityStatus::Available->value)
            ->pluck('rider_user_id')
            ->map(fn ($id) => (int) $id)
            ->all();
    }

    /**
     * @return list<int>
     */
    private function getAvailableRidersInZone(int $zoneId): array
    {
        $riderIds = User::query()
            ->where('role', 'rider')
            ->where('status', 'active')
            ->pluck('id')
            ->all();

        return $this->filterAvailableRiders($riderIds, $zoneId);
    }

    private function appendHistory(Order $order, OrderStatus $status, ?int $changedByUserId): void
    {
        OrderStatusHistory::create([
            'order_id' => $order->id,
            'status' => $status->value,
            'changed_by_user_id' => $changedByUserId,
        ]);
    }
}
