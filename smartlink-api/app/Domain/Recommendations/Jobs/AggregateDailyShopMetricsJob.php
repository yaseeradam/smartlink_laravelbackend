<?php

namespace App\Domain\Recommendations\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class AggregateDailyShopMetricsJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(public readonly string $dateYmd)
    {
    }

    public function handle(): void
    {
        $date = Carbon::createFromFormat('Y-m-d', $this->dateYmd)->startOfDay();
        $start = $date->copy();
        $end = $date->copy()->endOfDay();

        $statusRows = DB::table('order_status_history as h')
            ->join('orders as o', 'o.id', '=', 'h.order_id')
            ->selectRaw('o.shop_id, o.zone_id,
                SUM(CASE WHEN h.status = "paid" THEN 1 ELSE 0 END) AS orders_count,
                SUM(CASE WHEN h.status = "confirmed" THEN 1 ELSE 0 END) AS completed_orders_count,
                SUM(CASE WHEN h.status = "cancelled" THEN 1 ELSE 0 END) AS cancelled_orders_count,
                SUM(CASE WHEN h.status = "disputed" THEN 1 ELSE 0 END) AS disputes_count')
            ->whereBetween('h.created_at', [$start, $end])
            ->groupBy('o.shop_id', 'o.zone_id')
            ->get();

        $ratingRows = DB::table('ratings as r')
            ->join('orders as o', 'o.id', '=', 'r.order_id')
            ->selectRaw('o.shop_id, o.zone_id,
                AVG(r.stars) AS avg_rating,
                COUNT(*) AS ratings_count')
            ->where('r.ratee_type', '=', 'seller')
            ->whereBetween('r.created_at', [$start, $end])
            ->groupBy('o.shop_id', 'o.zone_id')
            ->get();

        $prepRows = DB::select(
            'SELECT o.shop_id, o.zone_id, AVG(TIMESTAMPDIFF(MINUTE, fe.first_event_at, te.trigger_event_at)) AS avg_prep_minutes
            FROM orders o
            JOIN (
                SELECT order_id, MIN(created_at) AS first_event_at
                FROM order_workflow_events
                GROUP BY order_id
            ) fe ON fe.order_id = o.id
            JOIN (
                SELECT e.order_id, MIN(e.created_at) AS trigger_event_at
                FROM order_workflow_events e
                JOIN workflow_steps ws ON ws.id = e.to_step_id
                WHERE ws.is_dispatch_trigger = 1
                GROUP BY e.order_id
            ) te ON te.order_id = o.id
            WHERE o.service_type = "food"
              AND te.trigger_event_at BETWEEN ? AND ?
            GROUP BY o.shop_id, o.zone_id',
            [$start->toDateTimeString(), $end->toDateTimeString()],
        );

        $byShop = [];

        foreach ($statusRows as $row) {
            $key = (int) $row->shop_id;
            $byShop[$key] = [
                'shop_id' => (int) $row->shop_id,
                'zone_id' => (int) $row->zone_id,
                'date' => $this->dateYmd,
                'orders_count' => (int) $row->orders_count,
                'completed_orders_count' => (int) $row->completed_orders_count,
                'cancelled_orders_count' => (int) $row->cancelled_orders_count,
                'disputes_count' => (int) $row->disputes_count,
                'avg_rating' => 0,
                'ratings_count' => 0,
                'avg_delivery_minutes' => null,
                'avg_prep_minutes' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        foreach ($ratingRows as $row) {
            $key = (int) $row->shop_id;
            $byShop[$key] ??= [
                'shop_id' => (int) $row->shop_id,
                'zone_id' => (int) $row->zone_id,
                'date' => $this->dateYmd,
                'orders_count' => 0,
                'completed_orders_count' => 0,
                'cancelled_orders_count' => 0,
                'disputes_count' => 0,
                'avg_rating' => 0,
                'ratings_count' => 0,
                'avg_delivery_minutes' => null,
                'avg_prep_minutes' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ];

            $byShop[$key]['avg_rating'] = round((float) $row->avg_rating, 3);
            $byShop[$key]['ratings_count'] = (int) $row->ratings_count;
        }

        foreach ($prepRows as $row) {
            $key = (int) $row->shop_id;
            $byShop[$key] ??= [
                'shop_id' => (int) $row->shop_id,
                'zone_id' => (int) $row->zone_id,
                'date' => $this->dateYmd,
                'orders_count' => 0,
                'completed_orders_count' => 0,
                'cancelled_orders_count' => 0,
                'disputes_count' => 0,
                'avg_rating' => 0,
                'ratings_count' => 0,
                'avg_delivery_minutes' => null,
                'avg_prep_minutes' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ];

            $minutes = isset($row->avg_prep_minutes) ? (int) round((float) $row->avg_prep_minutes) : null;
            $byShop[$key]['avg_prep_minutes'] = $minutes !== null && $minutes >= 0 ? $minutes : null;
        }

        if ($byShop === []) {
            return;
        }

        DB::table('shop_metrics_daily')->upsert(
            array_values($byShop),
            ['shop_id', 'date'],
            [
                'zone_id',
                'orders_count',
                'completed_orders_count',
                'cancelled_orders_count',
                'disputes_count',
                'avg_rating',
                'ratings_count',
                'avg_delivery_minutes',
                'avg_prep_minutes',
                'updated_at',
            ],
        );
    }
}

