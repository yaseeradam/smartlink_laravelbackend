<?php

namespace App\Services;

use App\Domain\Recommendations\Models\ShopCooccurrence;
use App\Domain\Recommendations\Models\UserFavorite;
use App\Domain\Recommendations\Models\UserPreference;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use BackedEnum;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class RecommendationService
{
    /** @var array<int, array{city:?string, state:?string}> */
    private array $zoneGeoCache = [];

    /**
     * @return array<string, array{items: list<array<string, mixed>>}>
     */
    public function getHomeBlocks(?User $user, int $zoneId, ?float $lat, ?float $lng, ?string $scope = null): array
    {
        $blocks = [];

        $blocks['near_you'] = [
            'items' => $this->getNearYou($user, $zoneId, $lat, $lng, 10),
        ];

        $blocks['in_your_state'] = [
            'items' => $this->getInYourState($user, $zoneId, $lat, $lng, 10),
        ];

        $blocks['across_nigeria'] = [
            'items' => $this->getAcrossNigeria($user, $zoneId, $lat, $lng, 10),
        ];

        $blocks['trending'] = [
            'items' => $this->getTrending($zoneId, 7, 10, $scope),
        ];

        $blocks['for_you'] = [
            'items' => $user
                ? $this->getForYou($user, $zoneId, 10, $lat, $lng, 'auto')
                : $this->getTrustFirstFallback($zoneId, 10, $lat, $lng),
        ];

        $hasFood = Shop::query()
            ->where('zone_id', $zoneId)
            ->where('shop_type', 'food')
            ->where('is_verified', true)
            ->where('status', 'active')
            ->exists();

        if ($hasFood) {
            $blocks['ready_soon'] = [
                'items' => $this->getReadySoon($zoneId, $lat, $lng, 10),
            ];
        }

        return $blocks;
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function getNearYou(?User $user, int $zoneId, ?float $lat, ?float $lng, int $limit = 20): array
    {
        $ttl = (int) config('recommendations.cache_ttl_seconds.near_you', 300);
        $bucket = $this->geoBucket($lat, $lng);
        $key = "rec:v2:near_you:zone:{$zoneId}:bkt:{$bucket}";

        return Cache::remember($key, $ttl, function () use ($user, $zoneId, $lat, $lng, $limit) {
            $candidates = $this->shopCandidates(
                zoneId: $zoneId,
                lat: $lat,
                lng: $lng,
                requireOpenNow: true,
                relaxOpenIfTooSmall: false,
                candidateLimit: 250,
                scope: 'local',
                radiusKm: (float) config('recommendations.near_you_radius_km', 10.0),
            );

            return $this->rankShops($candidates, $user, $zoneId, $lat, $lng, $limit, context: 'near_you');
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function getInYourState(?User $user, int $zoneId, ?float $lat, ?float $lng, int $limit = 20): array
    {
        $ttl = (int) config('recommendations.cache_ttl_seconds.near_you', 300);
        $bucket = $this->geoBucket($lat, $lng);
        $key = "rec:v2:in_your_state:zone:{$zoneId}:bkt:{$bucket}";

        return Cache::remember($key, $ttl, function () use ($user, $zoneId, $lat, $lng, $limit) {
            return $user
                ? $this->getScopedFeed($user, $zoneId, $limit, $lat, $lng, scope: 'state', context: 'for_you')
                : $this->getScopedFeed(null, $zoneId, $limit, $lat, $lng, scope: 'state', context: 'trust_first');
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function getAcrossNigeria(?User $user, int $zoneId, ?float $lat, ?float $lng, int $limit = 20): array
    {
        $ttl = (int) config('recommendations.cache_ttl_seconds.near_you', 300);
        $bucket = $this->geoBucket($lat, $lng);
        $key = "rec:v2:across_nigeria:zone:{$zoneId}:bkt:{$bucket}";

        return Cache::remember($key, $ttl, function () use ($user, $zoneId, $lat, $lng, $limit) {
            return $user
                ? $this->getScopedFeed($user, $zoneId, $limit, $lat, $lng, scope: 'national', context: 'for_you')
                : $this->getScopedFeed(null, $zoneId, $limit, $lat, $lng, scope: 'national', context: 'trust_first');
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function getTrending(int $zoneId, int $days = 7, int $limit = 20, ?string $scope = null): array
    {
        $ttl = (int) config('recommendations.cache_ttl_seconds.trending', 300);
        $scopeNorm = $this->normalizeScope($scope, default: 'state');
        $key = "rec:v2:trending:zone:{$zoneId}:days:{$days}:scope:{$scopeNorm}";

        return Cache::remember($key, $ttl, function () use ($zoneId, $days, $limit, $scopeNorm) {
            $effectiveScope = $scopeNorm === 'national' ? 'national' : 'state';
            $candidates = $this->shopCandidates(
                zoneId: $zoneId,
                lat: null,
                lng: null,
                requireOpenNow: true,
                relaxOpenIfTooSmall: true,
                candidateLimit: 300,
                popularityWindowDays: $days,
                scope: $effectiveScope,
            );

            return $this->rankShops($candidates, null, $zoneId, null, null, $limit, context: 'trending');
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function getTopRated(int $zoneId, int $limit = 20, ?string $scope = null): array
    {
        $ttl = (int) config('recommendations.cache_ttl_seconds.top_rated', 300);
        $scopeNorm = $this->normalizeScope($scope, default: 'state');
        $key = "rec:v2:top_rated:zone:{$zoneId}:scope:{$scopeNorm}";

        return Cache::remember($key, $ttl, function () use ($zoneId, $limit, $scopeNorm) {
            $effectiveScope = $scopeNorm === 'national' ? 'national' : 'state';
            $candidates = $this->shopCandidates(
                zoneId: $zoneId,
                lat: null,
                lng: null,
                requireOpenNow: true,
                relaxOpenIfTooSmall: true,
                candidateLimit: 300,
                scope: $effectiveScope,
            );

            return $this->rankShops($candidates, null, $zoneId, null, null, $limit, context: 'top_rated');
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function getForYou(User $user, int $zoneId, int $limit = 20, ?float $lat = null, ?float $lng = null, ?string $scope = null): array
    {
        $ttl = (int) config('recommendations.cache_ttl_seconds.for_you', 60);
        $bucket = $this->geoBucket($lat, $lng);
        $scopeNorm = $this->normalizeScope($scope, default: 'auto');
        $key = "rec:v2:for_you:user:{$user->id}:zone:{$zoneId}:bkt:{$bucket}:scope:{$scopeNorm}";

        return Cache::remember($key, $ttl, function () use ($user, $zoneId, $limit, $lat, $lng, $scopeNorm) {
            $ranked = $this->getScopedFeed($user, $zoneId, $limit, $lat, $lng, scope: $scopeNorm, context: 'for_you');

            // Collaborative filtering lite: add a small subset of "you might like".
            $youMightLike = $this->cooccurrenceSuggestions(
                $user,
                $zoneId,
                $ranked,
                max(3, (int) floor($limit * 0.3)),
            );
            if ($youMightLike !== []) {
                $youIds = array_fill_keys(array_map(fn ($i) => (int) $i['entity_id'], $youMightLike), true);
                $merged = $youMightLike;
                foreach ($ranked as $item) {
                    if (! isset($youIds[(int) $item['entity_id']])) {
                        $merged[] = $item;
                    }
                }

                return array_slice($merged, 0, $limit);
            }

            return $ranked;
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function getForYouFallback(int $zoneId, int $limit = 20, ?float $lat = null, ?float $lng = null, ?string $scope = null): array
    {
        $ttl = (int) config('recommendations.cache_ttl_seconds.for_you', 60);
        $bucket = $this->geoBucket($lat, $lng);
        $scopeNorm = $this->normalizeScope($scope, default: 'auto');
        $key = "rec:v2:for_you:anon:zone:{$zoneId}:bkt:{$bucket}:scope:{$scopeNorm}";

        return Cache::remember($key, $ttl, function () use ($zoneId, $limit, $lat, $lng, $scopeNorm) {
            return $this->getScopedFeed(null, $zoneId, $limit, $lat, $lng, scope: $scopeNorm, context: 'trust_first');
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function getReadySoon(int $zoneId, ?float $lat, ?float $lng, int $limit = 20): array
    {
        $ttl = (int) config('recommendations.cache_ttl_seconds.ready_soon', 300);
        $bucket = $this->geoBucket($lat, $lng);
        $key = "rec:v2:ready_soon:zone:{$zoneId}:bkt:{$bucket}";

        return Cache::remember($key, $ttl, function () use ($zoneId, $lat, $lng, $limit) {
            $candidates = $this->shopCandidates(
                zoneId: $zoneId,
                lat: $lat,
                lng: $lng,
                requireOpenNow: true,
                relaxOpenIfTooSmall: false,
                candidateLimit: 250,
                shopTypeOnly: 'food',
            );

            return $this->rankShops($candidates, null, $zoneId, $lat, $lng, $limit, context: 'ready_soon');
        });
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function getTrustFirstFallback(int $zoneId, int $limit, ?float $lat, ?float $lng): array
    {
        $candidates = $this->shopCandidates(
            zoneId: $zoneId,
            lat: $lat,
            lng: $lng,
            requireOpenNow: true,
            relaxOpenIfTooSmall: true,
            candidateLimit: 300,
            scope: 'zone',
        );

        return $this->rankShops($candidates, null, $zoneId, $lat, $lng, $limit, context: 'trust_first');
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function getScopedFeed(?User $user, int $zoneId, int $limit, ?float $lat, ?float $lng, string $scope, string $context): array
    {
        $scopeNorm = $this->normalizeScope($scope, default: 'auto');

        if ($scopeNorm !== 'auto') {
            $candidates = $this->shopCandidates(
                zoneId: $zoneId,
                lat: $lat,
                lng: $lng,
                requireOpenNow: true,
                relaxOpenIfTooSmall: true,
                candidateLimit: 400,
                scope: $scopeNorm,
                radiusKm: (float) config('recommendations.near_you_radius_km', 10.0),
            );

            return $this->rankShops($candidates, $user, $zoneId, $lat, $lng, $limit, context: $context);
        }

        $out = [];
        $seen = [];
        foreach (['local', 'state', 'national'] as $tier) {
            $remaining = $limit - count($out);
            if ($remaining <= 0) {
                break;
            }

            $candidates = $this->shopCandidates(
                zoneId: $zoneId,
                lat: $lat,
                lng: $lng,
                requireOpenNow: true,
                relaxOpenIfTooSmall: true,
                candidateLimit: 450,
                scope: $tier,
                radiusKm: (float) config('recommendations.near_you_radius_km', 10.0),
            );

            if ($seen !== []) {
                $candidates = array_values(array_filter($candidates, function ($row) use ($seen) {
                    $id = (int) ($row['id'] ?? 0);
                    return $id > 0 && ! isset($seen[$id]);
                }));
            }

            $rankedTier = $this->rankShops($candidates, $user, $zoneId, $lat, $lng, $remaining, context: $context);
            foreach ($rankedTier as $item) {
                $sid = (int) ($item['entity_id'] ?? 0);
                if ($sid <= 0 || isset($seen[$sid])) {
                    continue;
                }
                $seen[$sid] = true;
                $out[] = $item;

                if (count($out) >= $limit) {
                    break 2;
                }
            }
        }

        return $out;
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function shopCandidates(
        int $zoneId,
        ?float $lat,
        ?float $lng,
        bool $requireOpenNow,
        bool $relaxOpenIfTooSmall,
        int $candidateLimit,
        int $popularityWindowDays = 7,
        ?string $shopTypeOnly = null,
        string $scope = 'zone',
        ?float $radiusKm = null,
    ): array {
        $scope = $this->normalizeScope($scope, default: 'zone');
        $radiusKm = $radiusKm ?? (float) config('recommendations.near_you_radius_km', 10.0);
        $countryCode = (string) config('smartlink.country_code', 'NG');
        $zoneGeo = $this->zoneGeo($zoneId);

        $sincePop = Carbon::now()->subDays($popularityWindowDays)->toDateString();
        $since30 = Carbon::now()->subDays(30)->toDateString();

        $buildQuery = function (bool $openOnly) use ($sincePop, $since30, $zoneId, $shopTypeOnly, $scope, $radiusKm, $countryCode, $zoneGeo, $lat, $lng) {
            $query = DB::table('shops as s')
                ->join('zones as z', 'z.id', '=', 's.zone_id')
                ->leftJoin('shop_trust_metrics as stm', 'stm.shop_id', '=', 's.id')
                ->leftJoinSub(
                    DB::table('shop_metrics_daily')
                        ->where('date', '>=', $sincePop)
                        ->groupBy('shop_id')
                        ->selectRaw('shop_id, SUM(completed_orders_count) AS completed_7d'),
                    'm7',
                    'm7.shop_id',
                    '=',
                    's.id',
                )
                ->leftJoinSub(
                    DB::table('shop_metrics_daily')
                        ->where('date', '>=', $since30)
                        ->groupBy('shop_id')
                        ->selectRaw('shop_id, SUM(ratings_count) AS ratings_30d, AVG(NULLIF(avg_prep_minutes,0)) AS avg_prep_minutes_30d'),
                    'm30',
                    'm30.shop_id',
                    '=',
                    's.id',
                )
                ->where('s.status', 'active')
                ->where('s.is_verified', true)
                ->where('z.is_active', true)
                ->where('z.status', 'active')
                ->when($shopTypeOnly, fn ($q) => $q->where('s.shop_type', $shopTypeOnly))
                ->when($openOnly, fn ($q) => $q->where('s.is_open', true))
                ->select([
                's.id',
                's.seller_user_id',
                's.shop_name',
                's.description',
                's.zone_id',
                's.country_code',
                's.state_code',
                's.city',
                's.address_text',
                's.shop_type',
                's.is_open',
                's.operating_hours_json',
                's.latitude',
                's.longitude',
                's.shipping_type',
                's.created_at',
                'z.city as zone_city',
                'z.state as zone_state',
                DB::raw('COALESCE(s.city, z.city) AS shop_city'),
                DB::raw("COALESCE(NULLIF(s.state_code, ''), z.state) AS shop_state_code"),
                DB::raw('COALESCE(stm.trust_score, 0) AS trust_score'),
                DB::raw('COALESCE(stm.rating_bayesian, 0) AS rating_bayesian'),
                DB::raw('COALESCE(m7.completed_7d, 0) AS completed_7d'),
                DB::raw('COALESCE(m30.ratings_30d, 0) AS ratings_30d'),
                DB::raw('m30.avg_prep_minutes_30d AS avg_prep_minutes_30d'),
                ])
                ->orderByDesc('trust_score')
                ->orderBy('s.id');

            $this->applyGeoScopeToQuery(
                $query,
                zoneId: $zoneId,
                buyerState: is_string($zoneGeo['state'] ?? null) ? (string) $zoneGeo['state'] : null,
                countryCode: $countryCode,
                lat: $lat,
                lng: $lng,
                scope: $scope,
                radiusKm: $radiusKm,
            );

            return $query;
        };

        $rows = $buildQuery($requireOpenNow)->limit($candidateLimit)->get()->map(fn ($r) => (array) $r)->all();
        $rows = $this->filterOpenNowIfSchedule($rows, $requireOpenNow);
        $rows = $this->filterByRadiusIfNeeded($rows, $lat, $lng, $scope, $radiusKm);

        if ($relaxOpenIfTooSmall && count($rows) < 20) {
            $relaxed = $buildQuery(false)
                ->limit($candidateLimit)
                ->get()
                ->map(fn ($r) => (array) $r)
                ->all();

            // Do not include closed shops in near-you.
            $rows = $this->filterByRadiusIfNeeded($relaxed, $lat, $lng, $scope, $radiusKm);
        }

        return $rows;
    }

    private function filterByRadiusIfNeeded(array $rows, ?float $lat, ?float $lng, string $scope, float $radiusKm): array
    {
        if ($scope !== 'local' || $lat === null || $lng === null) {
            return $rows;
        }

        $out = [];
        foreach ($rows as $row) {
            $d = $this->distanceKm($lat, $lng, $row['latitude'] ?? null, $row['longitude'] ?? null);
            if ($d !== null && $d <= $radiusKm) {
                $out[] = $row;
            }
        }

        return $out;
    }

    private function applyGeoScopeToQuery(
        $query,
        int $zoneId,
        ?string $buyerState,
        string $countryCode,
        ?float $lat,
        ?float $lng,
        string $scope,
        float $radiusKm,
    ): void {
        if ($scope === 'zone') {
            $query->where('s.zone_id', $zoneId);
            return;
        }

        if ($scope === 'national') {
            $query->where('s.country_code', $countryCode);
            return;
        }

        if ($buyerState) {
            $query->where(function ($q) use ($buyerState) {
                $q->where('s.state_code', $buyerState)
                    ->orWhere(function ($q2) use ($buyerState) {
                        $q2->whereNull('s.state_code')->where('z.state', $buyerState);
                    });
            });
        }

        if ($scope === 'state') {
            if (! $buyerState) {
                $query->where('s.zone_id', $zoneId);
            }
            return;
        }

        // local
        if ($lat === null || $lng === null) {
            $query->where('s.zone_id', $zoneId);
            return;
        }

        $query->where('s.country_code', $countryCode);
        $query->whereNotNull('s.latitude')->whereNotNull('s.longitude');

        $deltaLat = $radiusKm / 111.0;
        $cos = cos(deg2rad($lat));
        $deltaLng = $radiusKm / (111.0 * max(0.01, abs($cos)));

        $query->whereBetween('s.latitude', [$lat - $deltaLat, $lat + $deltaLat]);
        $query->whereBetween('s.longitude', [$lng - $deltaLng, $lng + $deltaLng]);
    }

    private function normalizeScope(?string $scope, string $default): string
    {
        $s = strtolower(trim((string) $scope));
        return match ($s) {
            'local', 'state', 'national', 'auto', 'zone' => $s,
            default => $default,
        };
    }

    /**
     * @return array{city: ?string, state: ?string}
     */
    private function zoneGeo(int $zoneId): array
    {
        if (isset($this->zoneGeoCache[$zoneId])) {
            return $this->zoneGeoCache[$zoneId];
        }

        $row = DB::table('zones')->where('id', $zoneId)->first(['city', 'state']);

        $this->zoneGeoCache[$zoneId] = [
            'city' => $row ? (string) $row->city : null,
            'state' => $row ? (string) $row->state : null,
        ];

        return $this->zoneGeoCache[$zoneId];
    }

    /**
     * @param  list<array<string, mixed>>  $rows
     * @return list<array<string, mixed>>
     */
    private function filterOpenNowIfSchedule(array $rows, bool $requireOpenNow): array
    {
        if (! $requireOpenNow) {
            return $rows;
        }

        $now = Carbon::now();
        $dow = strtolower($now->format('D')); // mon,tue...
        $time = $now->format('H:i');

        $out = [];
        foreach ($rows as $row) {
            $hours = $row['operating_hours_json'] ?? null;
            if (! is_array($hours) || ! isset($hours[$dow])) {
                if (! empty($row['is_open'])) {
                    $out[] = $row;
                }
                continue;
            }

            $windows = $hours[$dow];
            $open = false;
            if (is_array($windows)) {
                foreach ($windows as $w) {
                    if (! is_array($w) || count($w) < 2) {
                        continue;
                    }
                    $start = (string) $w[0];
                    $end = (string) $w[1];
                    if ($start <= $time && $time <= $end) {
                        $open = true;
                        break;
                    }
                }
            }

            if ($open) {
                $out[] = $row;
            }
        }

        return $out;
    }

    /**
     * @param  list<array<string, mixed>>  $candidates
     * @return list<array<string, mixed>>
     */
    private function rankShops(array $candidates, ?User $user, int $zoneId, ?float $lat, ?float $lng, int $limit, string $context): array
    {
        if ($candidates === []) {
            return [];
        }

        $debug = (bool) config('recommendations.debug', false) || app()->environment('local');

        $buyerGeo = $this->zoneGeo($zoneId);
        $buyerCity = $buyerGeo['city'];
        $buyerState = $buyerGeo['state'];

        $tagsByShopId = $this->tagsForShops(array_map(fn ($r) => (int) $r['id'], $candidates));

        $userTags = $user ? $this->preferredTags($user) : [];
        $userOrderedShopIds = $user ? $this->userOrderedShopIds($user, $zoneId) : [];
        $excludedShopIds = $user ? $this->userInteractedShopIds($user, $zoneId) : [];

        $maxCompleted = max(1, max(array_map(fn ($r) => (int) $r['completed_7d'], $candidates)));

        $coldStart = $this->isColdStart($candidates);

        $ranked = [];
        foreach ($candidates as $row) {
            $shopId = (int) $row['id'];

            if ($user && in_array($shopId, $excludedShopIds, true) && $context === 'for_you') {
                continue;
            }

            $trust = max(0.0, min(1.0, ((float) $row['trust_score']) / 100.0));
            $distanceScore = $this->distanceScore($lat, $lng, $row['latitude'] ?? null, $row['longitude'] ?? null);
            $popularity = $coldStart ? 0.0 : $this->popularityScore((int) $row['completed_7d'], $maxCompleted);
            $rating = max(0.0, min(1.0, (float) $row['rating_bayesian']));
            $freshness = $this->freshnessBoost($row['created_at'] ?? null);

            $personal = 0.0;
            if (! $coldStart && $user) {
                $personal = $this->personalizationScore(
                    $userTags,
                    $tagsByShopId[$shopId] ?? [],
                    isset($userOrderedShopIds[$shopId]),
                    (string) $row['shop_type'],
                );
            }

            $readyBoost = 0.0;
            if ((string) $row['shop_type'] === 'food') {
                $readyBoost = $this->workflowReadyBoost($row['avg_prep_minutes_30d'] ?? null);
            }

            $shopCity = $row['shop_city'] ?? $row['city'] ?? $row['zone_city'] ?? null;
            $shopState = $row['shop_state_code'] ?? $row['state_code'] ?? $row['zone_state'] ?? null;
            $locationPenalty = $this->locationTierPenalty($buyerCity, $buyerState, $shopCity, $shopState);

            $score = 0.0;
            if ($coldStart) {
                $score = (0.55 * $trust) + (0.35 * $distanceScore) + (0.10 * $freshness);
            } else {
                $score = (0.45 * $trust)
                    + (0.20 * $distanceScore)
                    + (0.15 * $popularity)
                    + (0.10 * $rating)
                    + (0.07 * ($user ? $personal : 0.0))
                    + (0.03 * $freshness)
                    + $readyBoost;
            }

            $score = round(max(0.0, $score + $locationPenalty), 6);

            $badges = [];
            if ($trust >= 0.8) {
                $badges[] = 'trusted';
            }
            if ($freshness > 0) {
                $badges[] = 'new';
            }
            if ((int) $row['completed_7d'] > 0 && $context === 'trending') {
                $badges[] = 'trending';
            }
            if ((string) $row['shop_type'] === 'food' && $readyBoost > 0) {
                $badges[] = 'fast_prep';
            }

            $item = [
                'entity_type' => 'shop',
                'entity_id' => $shopId,
                'title' => (string) $row['shop_name'],
                'subtitle' => $this->subtitleForShopRow($row),
                'image_url' => null,
                'score' => (float) $score,
                'badges' => $badges,
                'meta' => [
                    'zone_id' => (int) $row['zone_id'],
                    'shop_type' => (string) $row['shop_type'],
                    'is_open' => (bool) $row['is_open'],
                    'distance_km' => $this->distanceKm($lat, $lng, $row['latitude'] ?? null, $row['longitude'] ?? null),
                    'geo_tier' => $this->geoTier($buyerCity, $buyerState, $shopCity, $shopState),
                    'state_code' => $shopState,
                    'city' => $shopCity,
                    'shipping_type' => $row['shipping_type'] ?? null,
                ],
            ];

            if ($debug) {
                $item['score_breakdown'] = [
                    'cold_start' => $coldStart,
                    'trust' => $trust,
                    'distance' => $distanceScore,
                    'popularity' => $popularity,
                    'rating' => $rating,
                    'personalization' => $personal,
                    'freshness' => $freshness,
                    'ready_boost' => $readyBoost,
                    'location_penalty' => $locationPenalty,
                ];
                $item['rank_reason'] = $coldStart ? 'cold_start_fallback' : $context;
            }

            $ranked[] = [
                'shop_id' => $shopId,
                'seller_user_id' => (int) $row['seller_user_id'],
                'shop_type' => (string) $row['shop_type'],
                'score' => $score,
                'item' => $item,
            ];
        }

        usort($ranked, function ($a, $b) {
            if ($a['score'] === $b['score']) {
                return $a['shop_id'] <=> $b['shop_id'];
            }

            return $b['score'] <=> $a['score'];
        });

        $items = array_map(fn ($r) => $r['item'], $this->applyDiversity($ranked));

        return array_slice($items, 0, $limit);
    }

    private function locationTierPenalty(?string $buyerCity, ?string $buyerState, $shopCity, $shopState): float
    {
        $bc = $this->normalizePlace($buyerCity);
        $bs = $this->normalizePlace($buyerState);
        $sc = $this->normalizePlace(is_string($shopCity) ? $shopCity : null);
        $ss = $this->normalizePlace(is_string($shopState) ? $shopState : null);

        if (! $bs || ! $ss) {
            return 0.0;
        }

        $penalties = (array) config('recommendations.geo_penalties', []);

        if ($bc && $sc && $bc === $sc) {
            return (float) ($penalties['same_city'] ?? 0.0);
        }

        if ($bs === $ss) {
            return (float) ($penalties['same_state'] ?? -0.05);
        }

        return (float) ($penalties['other_state'] ?? -0.12);
    }

    private function geoTier(?string $buyerCity, ?string $buyerState, $shopCity, $shopState): ?string
    {
        $bc = $this->normalizePlace($buyerCity);
        $bs = $this->normalizePlace($buyerState);
        $sc = $this->normalizePlace(is_string($shopCity) ? $shopCity : null);
        $ss = $this->normalizePlace(is_string($shopState) ? $shopState : null);

        if (! $bs || ! $ss) {
            return null;
        }

        if ($bs !== $ss) {
            return 'national';
        }

        if ($bc && $sc && $bc === $sc) {
            return 'city';
        }

        return 'state';
    }

    private function normalizePlace(?string $value): ?string
    {
        $v = strtolower(trim((string) $value));
        return $v !== '' ? $v : null;
    }

    /**
     * @param  list<array{shop_id:int,seller_user_id:int,shop_type:string,score:float,item:array<string,mixed>}>  $ranked
     * @return list<array{shop_id:int,seller_user_id:int,shop_type:string,score:float,item:array<string,mixed>}>
     */
    private function applyDiversity(array $ranked): array
    {
        $topK = (int) config('recommendations.diversity.top_k', 10);
        $maxPerSeller = (int) config('recommendations.diversity.max_per_seller_in_top_k', 2);
        $maxConsecutiveType = (int) config('recommendations.diversity.max_consecutive_same_shop_type', 2);

        $sellerCount = [];
        $out = [];
        $pool = $ranked;

        while ($pool !== []) {
            $pickedIndex = null;

            for ($i = 0; $i < count($pool); $i++) {
                $candidate = $pool[$i];

                if ($this->violatesConsecutiveType($out, (string) $candidate['shop_type'], $maxConsecutiveType)) {
                    continue;
                }

                if (count($out) < $topK) {
                    $sid = (int) $candidate['seller_user_id'];
                    if (($sellerCount[$sid] ?? 0) >= $maxPerSeller) {
                        continue;
                    }
                }

                $pickedIndex = $i;
                break;
            }

            if ($pickedIndex === null) {
                // Relax consecutive constraint before relaxing seller diversity in topK.
                for ($i = 0; $i < count($pool); $i++) {
                    $candidate = $pool[$i];
                    if (count($out) < $topK) {
                        $sid = (int) $candidate['seller_user_id'];
                        if (($sellerCount[$sid] ?? 0) >= $maxPerSeller) {
                            continue;
                        }
                    }
                    $pickedIndex = $i;
                    break;
                }
            }

            if ($pickedIndex === null && count($out) < $topK) {
                // Enforce seller diversity in topK even if it means returning fewer items.
                break;
            }

            if ($pickedIndex === null) {
                $pickedIndex = 0;
            }

            $picked = $pool[$pickedIndex];
            $out[] = $picked;

            if (count($out) <= $topK) {
                $sid = (int) $picked['seller_user_id'];
                $sellerCount[$sid] = ($sellerCount[$sid] ?? 0) + 1;
            }

            array_splice($pool, $pickedIndex, 1);
        }

        return $out;
    }

    /**
     * @param  list<array{shop_type:string}>  $current
     */
    private function violatesConsecutiveType(array $current, string $candidateType, int $maxConsecutive): bool
    {
        if ($maxConsecutive <= 0) {
            return false;
        }

        $n = count($current);
        if ($n < $maxConsecutive) {
            return false;
        }

        for ($i = $n - $maxConsecutive; $i < $n; $i++) {
            if (($current[$i]['shop_type'] ?? null) !== $candidateType) {
                return false;
            }
        }

        return true;
    }

    private function popularityScore(int $x, int $maxX): float
    {
        $x = max(0, $x);
        $maxX = max(1, $maxX);
        return log(1 + $x) / log(1 + $maxX);
    }

    private function freshnessBoost($createdAt): float
    {
        if (! $createdAt) {
            return 0.0;
        }
        $created = Carbon::parse($createdAt);
        $days = $created->diffInDays(Carbon::now());
        if ($days > 14) {
            return 0.0;
        }

        // 0.05 on day 0 down to 0.02 on day 14.
        $t = max(0.0, min(1.0, (14 - $days) / 14));
        return round(0.02 + (0.03 * $t), 6);
    }

    private function workflowReadyBoost($avgPrepMinutes): float
    {
        if ($avgPrepMinutes === null) {
            return 0.0;
        }
        $prep = max(0.0, (float) $avgPrepMinutes);
        $p0 = 30.0;
        $boost = max(0.0, min(1.0, ($p0 - $prep) / $p0)) * 0.05;
        return round($boost, 6);
    }

    /**
     * @param  list<string>  $userTags
     * @param  list<string>  $shopTags
     */
    private function personalizationScore(array $userTags, array $shopTags, bool $isRepeatShop, string $shopType): float
    {
        if ($userTags === [] || $shopTags === []) {
            return $isRepeatShop ? 0.25 : 0.0;
        }

        $userSet = array_fill_keys($userTags, true);
        $hits = 0;
        foreach ($shopTags as $t) {
            if (isset($userSet[$t])) {
                $hits++;
            }
        }

        $score = $hits / max(count($userTags), 1);
        if ($isRepeatShop) {
            $score += 0.15;
        }

        $hour = (int) Carbon::now()->format('G');
        if ($shopType === 'food' && (($hour >= 11 && $hour <= 14) || ($hour >= 18 && $hour <= 21))) {
            $score += 0.05;
        }

        return max(0.0, min(1.0, round($score, 6)));
    }

    private function distanceScore(?float $lat, ?float $lng, $shopLat, $shopLng): float
    {
        $d = $this->distanceKm($lat, $lng, $shopLat, $shopLng);
        if ($d === null) {
            return 0.5;
        }

        $d0 = (float) config('recommendations.distance_d0_km', 2.0);
        $d0 = $d0 > 0 ? $d0 : 2.0;

        return (float) round(exp(-$d / $d0), 6);
    }

    private function distanceKm(?float $lat, ?float $lng, $shopLat, $shopLng): ?float
    {
        if ($lat === null || $lng === null || $shopLat === null || $shopLng === null) {
            return null;
        }

        $lat2 = (float) $shopLat;
        $lng2 = (float) $shopLng;

        return $this->haversineKm($lat, $lng, $lat2, $lng2);
    }

    private function haversineKm(float $lat1, float $lng1, float $lat2, float $lng2): float
    {
        $earth = 6371.0;
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);
        $a = sin($dLat / 2) ** 2 + cos(deg2rad($lat1)) * cos(deg2rad($lat2)) * sin($dLng / 2) ** 2;
        $c = 2 * asin(min(1.0, sqrt($a)));

        return (float) round($earth * $c, 6);
    }

    private function geoBucket(?float $lat, ?float $lng): string
    {
        if ($lat === null || $lng === null) {
            return 'na';
        }

        // ~1km buckets: 0.01deg latitude ≈ 1.11km.
        $latB = number_format(round($lat, 2), 2, '.', '');
        $lngB = number_format(round($lng, 2), 2, '.', '');
        return "{$latB},{$lngB}";
    }

    /**
     * @param  list<int>  $shopIds
     * @return array<int, list<string>>
     */
    private function tagsForShops(array $shopIds): array
    {
        $rows = DB::table('shop_tags')
            ->whereIn('shop_id', array_values(array_unique($shopIds)))
            ->get(['shop_id', 'tag']);

        $out = [];
        foreach ($rows as $r) {
            $out[(int) $r->shop_id][] = (string) $r->tag;
        }
        return $out;
    }

    /**
     * @return list<string>
     */
    private function preferredTags(User $user): array
    {
        /** @var UserPreference|null $pref */
        $pref = UserPreference::query()->where('user_id', $user->id)->first();
        $tags = $pref?->preferred_tags_json ?? [];
        return is_array($tags) ? array_values(array_map('strval', $tags)) : [];
    }

    /**
     * @return array<int, true>
     */
    private function userOrderedShopIds(User $user, int $zoneId): array
    {
        $ids = DB::table('orders')
            ->where('buyer_user_id', $user->id)
            ->where('zone_id', $zoneId)
            ->where('status', 'confirmed')
            ->pluck('shop_id')
            ->all();

        return array_fill_keys(array_map('intval', $ids), true);
    }

    /**
     * Exclude shops already interacted with from "for you".
     *
     * @return list<int>
     */
    private function userInteractedShopIds(User $user, int $zoneId): array
    {
        $ordered = DB::table('orders')
            ->where('buyer_user_id', $user->id)
            ->where('zone_id', $zoneId)
            ->pluck('shop_id')
            ->all();

        $favorites = UserFavorite::query()
            ->where('user_id', $user->id)
            ->pluck('shop_id')
            ->all();

        return array_values(array_unique(array_map('intval', array_merge($ordered, $favorites))));
    }

    private function isColdStart(array $candidates): bool
    {
        if (count($candidates) < 10) {
            return true;
        }

        $withTrust = 0;
        $withRatings = 0;
        foreach ($candidates as $r) {
            if (((float) $r['trust_score']) > 0) {
                $withTrust++;
            }
            if (((int) $r['ratings_30d']) >= 3) {
                $withRatings++;
            }
        }

        $ratioTrust = $withTrust / max(count($candidates), 1);
        $ratioRatings = $withRatings / max(count($candidates), 1);

        return $ratioTrust < 0.3 || $ratioRatings < 0.3;
    }

    private function subtitleForShopRow(array $row): string
    {
        $type = (string) ($row['shop_type'] ?? '');
        $addr = (string) ($row['address_text'] ?? '');
        return trim(($type ? strtoupper($type) : '').($addr ? " • {$addr}" : ''));
    }

    private function shopTypeValue(mixed $shopType): string
    {
        if ($shopType instanceof BackedEnum) {
            return (string) $shopType->value;
        }

        return (string) $shopType;
    }

    /**
     * @param  list<array<string,mixed>>  $currentRanked
     * @return list<array<string,mixed>>
     */
    private function cooccurrenceSuggestions(User $user, int $zoneId, array $currentRanked, int $limit): array
    {
        if ($limit <= 0) {
            return [];
        }

        $debug = (bool) config('recommendations.debug', false) || app()->environment('local');

        $favoriteShopIds = UserFavorite::query()
            ->where('user_id', $user->id)
            ->orderByDesc('id')
            ->limit(10)
            ->pluck('shop_id')
            ->all();

        $orderedShopIds = DB::table('orders')
            ->where('buyer_user_id', $user->id)
            ->where('zone_id', $zoneId)
            ->where('status', 'confirmed')
            ->orderByDesc('id')
            ->limit(10)
            ->pluck('shop_id')
            ->all();

        $seedShopIds = array_values(array_unique(array_merge(array_map('intval', $favoriteShopIds), array_map('intval', $orderedShopIds))));
        $seedShopIds = array_slice($seedShopIds, 0, 5);

        if ($seedShopIds === []) {
            return [];
        }

        $existingIds = array_fill_keys(array_map(fn ($i) => (int) $i['entity_id'], $currentRanked), true);

        $pairs = ShopCooccurrence::query()
            ->where('zone_id', $zoneId)
            ->whereIn('shop_a_id', $seedShopIds)
            ->orderByDesc('weight')
            ->limit(50)
            ->get(['shop_a_id', 'shop_b_id', 'weight']);

        if ($pairs->isEmpty()) {
            return [];
        }

        $suggestedShopIds = [];
        foreach ($pairs as $p) {
            $sid = (int) $p->shop_b_id;
            if (isset($existingIds[$sid])) {
                continue;
            }
            $suggestedShopIds[] = $sid;
        }

        $suggestedShopIds = array_values(array_unique($suggestedShopIds));
        $suggestedShopIds = array_slice($suggestedShopIds, 0, $limit);

        if ($suggestedShopIds === []) {
            return [];
        }

        $shops = Shop::query()
            ->whereIn('id', $suggestedShopIds)
            ->where('zone_id', $zoneId)
            ->where('status', 'active')
            ->where('is_verified', true)
            ->get(['id', 'shop_name', 'address_text', 'shop_type', 'zone_id', 'is_open']);

        $items = [];
        foreach ($shops as $shop) {
            $shopType = $this->shopTypeValue($shop->shop_type);
            $item = [
                'entity_type' => 'shop',
                'entity_id' => (int) $shop->id,
                'title' => (string) $shop->shop_name,
                'subtitle' => trim(strtoupper($shopType).' • '.(string) $shop->address_text),
                'image_url' => null,
                'score' => 1.0,
                'badges' => ['you_might_like'],
                'meta' => [
                    'zone_id' => (int) $shop->zone_id,
                    'shop_type' => $shopType,
                    'is_open' => (bool) $shop->is_open,
                ],
            ];
            if ($debug) {
                $item['score_breakdown'] = ['cooccurrence_weight' => null];
                $item['rank_reason'] = 'cooccurrence';
            }
            $items[] = $item;
        }

        return $items;
    }
}
