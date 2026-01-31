<?php

namespace App\Domain\Recommendations\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class BuildCooccurrenceJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(public readonly int $days = 60)
    {
    }

    public function handle(): void
    {
        $since = Carbon::now()->subDays($this->days);

        $rows = DB::select(
            'SELECT o1.zone_id, o1.shop_id AS shop_a_id, o2.shop_id AS shop_b_id,
                SUM(POW(0.9, FLOOR(DATEDIFF(CURDATE(), DATE(o1.created_at)) / 7))) AS weight
            FROM orders o1
            JOIN orders o2
                ON o1.buyer_user_id = o2.buyer_user_id
                AND o1.zone_id = o2.zone_id
                AND o1.shop_id < o2.shop_id
            JOIN (
                SELECT buyer_user_id, zone_id
                FROM orders
                WHERE status = "confirmed" AND created_at >= ?
                GROUP BY buyer_user_id, zone_id
                HAVING COUNT(DISTINCT shop_id) >= 2
            ) u ON u.buyer_user_id = o1.buyer_user_id AND u.zone_id = o1.zone_id
            WHERE o1.status = "confirmed" AND o2.status = "confirmed"
                AND o1.created_at >= ? AND o2.created_at >= ?
            GROUP BY o1.zone_id, shop_a_id, shop_b_id',
            [$since->toDateTimeString(), $since->toDateTimeString(), $since->toDateTimeString()],
        );

        if ($rows === []) {
            return;
        }

        $now = now();
        $upserts = [];
        foreach ($rows as $row) {
            $upserts[] = [
                'zone_id' => (int) $row->zone_id,
                'shop_a_id' => (int) $row->shop_a_id,
                'shop_b_id' => (int) $row->shop_b_id,
                'weight' => round((float) $row->weight, 6),
                'updated_at' => $now,
            ];
        }

        DB::table('shop_cooccurrence')->upsert(
            $upserts,
            ['zone_id', 'shop_a_id', 'shop_b_id'],
            ['weight', 'updated_at'],
        );
    }
}

