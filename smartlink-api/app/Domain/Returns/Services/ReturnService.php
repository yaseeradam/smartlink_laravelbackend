<?php

namespace App\Domain\Returns\Services;

use App\Domain\Dispatch\Enums\DispatchJobStatus;
use App\Domain\Dispatch\Enums\DispatchPurpose;
use App\Domain\Dispatch\Jobs\BroadcastDispatchOffersJob;
use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Dispatch\Models\DispatchOffer;
use App\Domain\Notifications\Jobs\SendPushNotificationJob;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Returns\Enums\ReturnStatus;
use App\Domain\Returns\Models\ReturnRequest;
use App\Domain\Users\Models\User;
use Illuminate\Support\Facades\DB;

class ReturnService
{
    public function request(User $buyer, Order $order, string $reason): ReturnRequest
    {
        if ((int) $order->buyer_user_id !== (int) $buyer->id) {
            throw new \RuntimeException('Forbidden.');
        }

        if ($order->status !== OrderStatus::Confirmed) {
            throw new \RuntimeException('Returns are only allowed after confirmation.');
        }

        $windowHours = (int) config('smartlink.returns.window_hours', 48);
        $confirmedAt = OrderStatusHistory::query()
            ->where('order_id', $order->id)
            ->where('status', OrderStatus::Confirmed->value)
            ->latest('id')
            ->value('created_at');

        if (! $confirmedAt || now()->greaterThan($confirmedAt->copy()->addHours($windowHours))) {
            throw new \RuntimeException('Return window has expired.');
        }

        return ReturnRequest::firstOrCreate(
            ['order_id' => $order->id],
            ['status' => ReturnStatus::Requested, 'reason' => $reason],
        );
    }

    public function approve(User $admin, ReturnRequest $returnRequest): ReturnRequest
    {
        return DB::transaction(function () use ($admin, $returnRequest) {
            /** @var ReturnRequest $locked */
            $locked = ReturnRequest::query()->whereKey($returnRequest->id)->lockForUpdate()->firstOrFail();

            if ($locked->status !== ReturnStatus::Requested) {
                return $locked;
            }

            $locked->forceFill(['status' => ReturnStatus::Approved])->save();

            /** @var Order $order */
            $order = Order::query()->whereKey($locked->order_id)->firstOrFail();

            $job = DispatchJob::firstOrCreate(
                ['order_id' => $order->id, 'purpose' => DispatchPurpose::Return],
                [
                    'shop_id' => $order->shop_id,
                    'zone_id' => $order->zone_id,
                    'status' => DispatchJobStatus::Broadcasting,
                    'assigned_rider_user_id' => null,
                    'private_pool_only_until' => null,
                    'fallback_broadcast_at' => null,
                ],
            );
            if (! $job->wasRecentlyCreated && $job->status !== DispatchJobStatus::Broadcasting) {
                $job->forceFill([
                    'status' => DispatchJobStatus::Broadcasting,
                    'assigned_rider_user_id' => null,
                ])->save();
            }

            $preferredRiderId = $order->dispatchJob?->assigned_rider_user_id;
            if ($preferredRiderId) {
                DispatchOffer::firstOrCreate(
                    ['dispatch_job_id' => $job->id, 'rider_user_id' => $preferredRiderId],
                    [
                        'offer_status' => 'sent',
                        'offered_at' => now(),
                        'responded_at' => null,
                    ],
                );

                dispatch(new SendPushNotificationJob(
                    (int) $preferredRiderId,
                    'Return request',
                    'A return pickup is available for a recent order.',
                    ['order_id' => $order->id, 'dispatch_job_id' => $job->id, 'purpose' => 'return'],
                ));
            }

            $fallbackMinutes = (int) config('smartlink.returns.fallback_minutes', 10);
            dispatch((new BroadcastDispatchOffersJob($job->id, 'fallback'))->delay(now()->addMinutes($fallbackMinutes)));

            return $locked->fresh();
        });
    }

    public function reject(User $admin, ReturnRequest $returnRequest): ReturnRequest
    {
        return DB::transaction(function () use ($returnRequest) {
            /** @var ReturnRequest $locked */
            $locked = ReturnRequest::query()->whereKey($returnRequest->id)->lockForUpdate()->firstOrFail();

            if ($locked->status !== ReturnStatus::Requested) {
                return $locked;
            }

            $locked->forceFill(['status' => ReturnStatus::Rejected])->save();

            return $locked->fresh();
        });
    }

    public function complete(User $admin, ReturnRequest $returnRequest): ReturnRequest
    {
        return DB::transaction(function () use ($returnRequest) {
            /** @var ReturnRequest $locked */
            $locked = ReturnRequest::query()->whereKey($returnRequest->id)->lockForUpdate()->firstOrFail();

            if ($locked->status !== ReturnStatus::Approved) {
                return $locked;
            }

            $locked->forceFill(['status' => ReturnStatus::Completed])->save();

            return $locked->fresh();
        });
    }
}
