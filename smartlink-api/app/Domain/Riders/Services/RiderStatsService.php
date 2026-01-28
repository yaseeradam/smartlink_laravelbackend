<?php

namespace App\Domain\Riders\Services;

use App\Domain\Cancellations\Models\Cancellation;
use App\Domain\Dispatch\Models\DispatchOffer;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Riders\Models\RiderStat;
use Illuminate\Support\Facades\DB;

class RiderStatsService
{
    public function refresh(int $riderUserId): RiderStat
    {
        $totalOffers = DispatchOffer::query()
            ->where('rider_user_id', $riderUserId)
            ->count();

        $acceptedOffers = DispatchOffer::query()
            ->where('rider_user_id', $riderUserId)
            ->where('offer_status', 'accepted')
            ->count();

        $cancellations = Cancellation::query()
            ->where('cancelled_by_user_id', $riderUserId)
            ->count();

        $acceptanceRate = $totalOffers > 0 ? round(($acceptedOffers / $totalOffers) * 100, 2) : 0;
        $cancellationRate = $acceptedOffers > 0 ? round(($cancellations / $acceptedOffers) * 100, 2) : 0;

        $avgDeliveryTime = $this->calculateAverageDeliveryMinutes($riderUserId);

        return RiderStat::updateOrCreate(
            ['rider_user_id' => $riderUserId],
            [
                'acceptance_rate' => $acceptanceRate,
                'cancellation_rate' => $cancellationRate,
                'avg_delivery_time' => $avgDeliveryTime,
            ],
        );
    }

    private function calculateAverageDeliveryMinutes(int $riderUserId): float
    {
        $orderIds = DB::table('dispatch_jobs')
            ->where('assigned_rider_user_id', $riderUserId)
            ->where('purpose', 'delivery')
            ->pluck('order_id')
            ->all();

        if ($orderIds === []) {
            return 0;
        }

        $delivered = OrderStatusHistory::query()
            ->whereIn('order_id', $orderIds)
            ->where('status', 'delivered')
            ->get(['order_id', 'created_at']);

        $totalMinutes = 0;
        $count = 0;

        foreach ($delivered as $row) {
            $pickedUpAt = OrderStatusHistory::query()
                ->where('order_id', $row->order_id)
                ->where('status', 'picked_up')
                ->orderBy('id')
                ->value('created_at');

            if (! $pickedUpAt) {
                continue;
            }

            $totalMinutes += $row->created_at->diffInMinutes($pickedUpAt);
            $count++;
        }

        return $count > 0 ? round($totalMinutes / $count, 2) : 0;
    }
}
