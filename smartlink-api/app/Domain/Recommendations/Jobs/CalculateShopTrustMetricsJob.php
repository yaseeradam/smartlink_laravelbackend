<?php

namespace App\Domain\Recommendations\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class CalculateShopTrustMetricsJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(public readonly int $days = 30)
    {
    }

    public function handle(): void
    {
        $since = Carbon::now()->subDays($this->days)->toDateString();

        $global = DB::table('shop_metrics_daily')
            ->where('date', '>=', $since)
            ->where('ratings_count', '>', 0)
            ->selectRaw('SUM(avg_rating * ratings_count) / NULLIF(SUM(ratings_count),0) AS global_avg')
            ->first();

        $C = $global?->global_avg ? (float) $global->global_avg : 4.0;
        $m = (int) config('recommendations.bayesian.m', 5);

        $rows = DB::table('shop_metrics_daily')
            ->where('date', '>=', $since)
            ->groupBy('shop_id')
            ->selectRaw('shop_id,
                SUM(orders_count) AS orders,
                SUM(completed_orders_count) AS completed,
                SUM(cancelled_orders_count) AS cancels,
                SUM(disputes_count) AS disputes,
                SUM(ratings_count) AS ratings_count,
                (SUM(avg_rating * ratings_count) / NULLIF(SUM(ratings_count),0)) AS avg_rating')
            ->get();

        if ($rows->isEmpty()) {
            return;
        }

        $shopIds = $rows->pluck('shop_id')->all();

        $kycByShop = $this->kycLevelsForShops($shopIds);

        $now = now();
        $upserts = [];

        foreach ($rows as $row) {
            $orders = (int) $row->orders;
            $completed = (int) $row->completed;
            $cancels = (int) $row->cancels;
            $disputes = (int) $row->disputes;

            $successRate = $completed / max($orders, 1);
            $cancellationRate = $cancels / max($orders, 1);
            $disputeRate = $disputes / max($completed, 1);

            $v = (int) $row->ratings_count;
            $R = $row->avg_rating ? (float) $row->avg_rating : $C;
            $ratingBayes0to5 = ($v / max($v + $m, 1)) * $R + ($m / max($v + $m, 1)) * $C;
            $ratingBayesian = max(0.0, min(1.0, $ratingBayes0to5 / 5.0));

            $kycLevel = $kycByShop[(int) $row->shop_id] ?? 'none';

            $trustScore = $this->trustScore(
                $kycLevel,
                $ratingBayesian,
                $cancellationRate,
                $disputeRate,
                $successRate,
            );

            $upserts[] = [
                'shop_id' => (int) $row->shop_id,
                'trust_score' => round($trustScore, 2),
                'dispute_rate' => round($disputeRate, 6),
                'cancellation_rate' => round($cancellationRate, 6),
                'fulfillment_success_rate' => round($successRate, 6),
                'kyc_level' => $kycLevel,
                'rating_bayesian' => round($ratingBayesian, 3),
                'last_calculated_at' => $now,
                'created_at' => $now,
                'updated_at' => $now,
            ];
        }

        DB::table('shop_trust_metrics')->upsert(
            $upserts,
            ['shop_id'],
            [
                'trust_score',
                'dispute_rate',
                'cancellation_rate',
                'fulfillment_success_rate',
                'kyc_level',
                'rating_bayesian',
                'last_calculated_at',
                'updated_at',
            ],
        );
    }

    /**
     * @param  list<int>  $shopIds
     * @return array<int, 'none'|'basic'|'verified'>
     */
    private function kycLevelsForShops(array $shopIds): array
    {
        $shops = DB::table('shops')
            ->whereIn('id', $shopIds)
            ->get(['id', 'seller_user_id', 'is_verified']);

        $sellerIds = $shops->pluck('seller_user_id')->unique()->all();

        $approvedSellerKyc = DB::table('kyc_requests')
            ->whereIn('user_id', $sellerIds)
            ->where('kyc_type', 'seller')
            ->where('status', 'approved')
            ->pluck('user_id')
            ->all();
        $approvedSet = array_fill_keys(array_map('intval', $approvedSellerKyc), true);

        $out = [];
        foreach ($shops as $shop) {
            $isVerified = (bool) $shop->is_verified;
            if (! $isVerified) {
                $out[(int) $shop->id] = 'none';
                continue;
            }

            $out[(int) $shop->id] = isset($approvedSet[(int) $shop->seller_user_id]) ? 'verified' : 'basic';
        }

        return $out;
    }

    private function trustScore(string $kycLevel, float $ratingBayesian, float $cancellationRate, float $disputeRate, float $successRate): float
    {
        $base = 50.0;

        $kycBonus = match ($kycLevel) {
            'verified' => 10.0,
            'basic' => 5.0,
            default => 0.0,
        };

        $ratingContribution = $ratingBayesian * 20.0;
        $cancellationPenalty = min(1.0, max(0.0, $cancellationRate)) * 25.0;
        $disputePenalty = min(1.0, max(0.0, $disputeRate)) * 35.0;
        $successBonus = min(1.0, max(0.0, $successRate)) * 10.0;

        $score = $base + $kycBonus + $ratingContribution - $cancellationPenalty - $disputePenalty + $successBonus;

        return max(0.0, min(100.0, $score));
    }
}

