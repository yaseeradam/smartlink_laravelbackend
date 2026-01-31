<?php

namespace App\Domain\Recommendations\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class UpdateUserPreferencesJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(public readonly ?int $userId = null, public readonly int $days = 30)
    {
    }

    public function handle(): void
    {
        $since = Carbon::now()->subDays($this->days);

        $userIds = $this->userId
            ? [$this->userId]
            : DB::table('users')->where('status', 'active')->pluck('id')->all();

        foreach (array_chunk($userIds, 200) as $chunk) {
            $this->processUsers($chunk, $since);
        }
    }

    /**
     * @param  list<int>  $userIds
     */
    private function processUsers(array $userIds, Carbon $since): void
    {
        $events = DB::table('user_events')
            ->whereIn('user_id', $userIds)
            ->where('created_at', '>=', $since)
            ->whereIn('event_type', ['view_shop', 'view_product', 'place_order', 'favorite_shop'])
            ->get(['user_id', 'event_type', 'entity_type', 'entity_id']);

        if ($events->isEmpty()) {
            return;
        }

        $weights = [
            'view_shop' => 1,
            'view_product' => 1,
            'place_order' => 5,
            'favorite_shop' => 8,
        ];

        $shopIds = [];
        $productIds = [];
        foreach ($events as $e) {
            if ($e->entity_type === 'shop' && $e->entity_id) {
                $shopIds[] = (int) $e->entity_id;
            } elseif ($e->entity_type === 'product' && $e->entity_id) {
                $productIds[] = (int) $e->entity_id;
            }
        }

        $productToShop = [];
        if ($productIds !== []) {
            $productToShop = DB::table('products')
                ->whereIn('id', array_values(array_unique($productIds)))
                ->pluck('shop_id', 'id')
                ->all();
        }

        $allShopIds = array_values(array_unique(array_merge($shopIds, array_map('intval', array_values($productToShop)))));
        if ($allShopIds === []) {
            return;
        }

        $tagsByShop = DB::table('shop_tags')
            ->whereIn('shop_id', $allShopIds)
            ->get(['shop_id', 'tag'])
            ->groupBy('shop_id');

        $favoritesByUser = DB::table('user_favorites')
            ->whereIn('user_id', $userIds)
            ->get(['user_id', 'shop_id'])
            ->groupBy('user_id');

        $tagScoresByUser = [];

        foreach ($events as $e) {
            $uid = (int) $e->user_id;
            $w = (int) ($weights[$e->event_type] ?? 0);
            if ($w <= 0) {
                continue;
            }

            $shopId = null;
            if ($e->entity_type === 'shop' && $e->entity_id) {
                $shopId = (int) $e->entity_id;
            } elseif ($e->entity_type === 'product' && $e->entity_id) {
                $shopId = (int) ($productToShop[(int) $e->entity_id] ?? 0);
            }

            if (! $shopId) {
                continue;
            }

            foreach (($tagsByShop[$shopId] ?? collect()) as $tagRow) {
                $tag = (string) $tagRow->tag;
                $tagScoresByUser[$uid][$tag] = ($tagScoresByUser[$uid][$tag] ?? 0) + $w;
            }
        }

        foreach ($favoritesByUser as $uid => $rows) {
            foreach ($rows as $favRow) {
                $shopId = (int) $favRow->shop_id;
                foreach (($tagsByShop[$shopId] ?? collect()) as $tagRow) {
                    $tag = (string) $tagRow->tag;
                    $tagScoresByUser[(int) $uid][$tag] = ($tagScoresByUser[(int) $uid][$tag] ?? 0) + 10;
                }
            }
        }

        $now = now();
        $upserts = [];
        foreach ($tagScoresByUser as $uid => $tagScores) {
            arsort($tagScores);
            $topTags = array_slice(array_keys($tagScores), 0, 15);

            $upserts[] = [
                'user_id' => (int) $uid,
                'preferred_tags_json' => $topTags,
                'preferred_price_band' => null,
                'last_updated_at' => $now,
            ];
        }

        if ($upserts !== []) {
            DB::table('user_preferences')->upsert(
                $upserts,
                ['user_id'],
                ['preferred_tags_json', 'preferred_price_band', 'last_updated_at'],
            );
        }
    }
}
