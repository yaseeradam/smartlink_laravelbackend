<?php

namespace App\Domain\Recommendations\Controllers;

use App\Services\RecommendationService;
use Illuminate\Http\Request;

class FeedController
{
    public function __construct(private readonly RecommendationService $recommendationService)
    {
    }

    public function home(Request $request)
    {
        $zoneId = (int) $request->query('zone_id', 0);
        if ($zoneId <= 0) {
            return response()->json(['message' => 'zone_id is required.'], 422);
        }

        $lat = $request->query('lat') !== null ? (float) $request->query('lat') : null;
        $lng = $request->query('lng') !== null ? (float) $request->query('lng') : null;
        $scope = $request->query('scope');

        $blocks = $this->recommendationService->getHomeBlocks($request->user(), $zoneId, $lat, $lng, is_string($scope) ? $scope : null);

        return response()->json(['data' => $blocks]);
    }

    public function nearYou(Request $request)
    {
        $zoneId = (int) $request->query('zone_id', 0);
        if ($zoneId <= 0) {
            return response()->json(['message' => 'zone_id is required.'], 422);
        }

        $lat = $request->query('lat') !== null ? (float) $request->query('lat') : null;
        $lng = $request->query('lng') !== null ? (float) $request->query('lng') : null;

        [$page, $perPage] = $this->pageParams($request, 20);
        $items = $this->recommendationService->getNearYou($request->user(), $zoneId, $lat, $lng, $page * $perPage);

        return response()->json($this->paginate($items, $page, $perPage));
    }

    public function inYourState(Request $request)
    {
        $zoneId = (int) $request->query('zone_id', 0);
        if ($zoneId <= 0) {
            return response()->json(['message' => 'zone_id is required.'], 422);
        }

        $lat = $request->query('lat') !== null ? (float) $request->query('lat') : null;
        $lng = $request->query('lng') !== null ? (float) $request->query('lng') : null;

        [$page, $perPage] = $this->pageParams($request, 20);
        $items = $this->recommendationService->getInYourState($request->user(), $zoneId, $lat, $lng, $page * $perPage);

        return response()->json($this->paginate($items, $page, $perPage));
    }

    public function acrossNigeria(Request $request)
    {
        $zoneId = (int) $request->query('zone_id', 0);
        if ($zoneId <= 0) {
            return response()->json(['message' => 'zone_id is required.'], 422);
        }

        $lat = $request->query('lat') !== null ? (float) $request->query('lat') : null;
        $lng = $request->query('lng') !== null ? (float) $request->query('lng') : null;

        [$page, $perPage] = $this->pageParams($request, 20);
        $items = $this->recommendationService->getAcrossNigeria($request->user(), $zoneId, $lat, $lng, $page * $perPage);

        return response()->json($this->paginate($items, $page, $perPage));
    }

    public function trending(Request $request)
    {
        $zoneId = (int) $request->query('zone_id', 0);
        if ($zoneId <= 0) {
            return response()->json(['message' => 'zone_id is required.'], 422);
        }

        $days = (int) $request->query('days', 7);
        $days = max(1, min(30, $days));
        $scope = $request->query('scope');

        [$page, $perPage] = $this->pageParams($request, 20);
        $items = $this->recommendationService->getTrending($zoneId, $days, $page * $perPage, is_string($scope) ? $scope : null);

        return response()->json($this->paginate($items, $page, $perPage));
    }

    public function topRated(Request $request)
    {
        $zoneId = (int) $request->query('zone_id', 0);
        if ($zoneId <= 0) {
            return response()->json(['message' => 'zone_id is required.'], 422);
        }

        $scope = $request->query('scope');
        [$page, $perPage] = $this->pageParams($request, 20);
        $items = $this->recommendationService->getTopRated($zoneId, $page * $perPage, is_string($scope) ? $scope : null);

        return response()->json($this->paginate($items, $page, $perPage));
    }

    public function forYou(Request $request)
    {
        $zoneId = (int) $request->query('zone_id', 0);
        if ($zoneId <= 0) {
            return response()->json(['message' => 'zone_id is required.'], 422);
        }

        $lat = $request->query('lat') !== null ? (float) $request->query('lat') : null;
        $lng = $request->query('lng') !== null ? (float) $request->query('lng') : null;
        $scope = $request->query('scope');

        $user = $request->user();
        [$page, $perPage] = $this->pageParams($request, 20);

        $items = $user
            ? $this->recommendationService->getForYou($user, $zoneId, $page * $perPage, $lat, $lng, is_string($scope) ? $scope : null)
            : $this->recommendationService->getForYouFallback($zoneId, $page * $perPage, $lat, $lng, is_string($scope) ? $scope : null);

        return response()->json($this->paginate($items, $page, $perPage));
    }

    public function readySoon(Request $request)
    {
        $zoneId = (int) $request->query('zone_id', 0);
        if ($zoneId <= 0) {
            return response()->json(['message' => 'zone_id is required.'], 422);
        }

        $lat = $request->query('lat') !== null ? (float) $request->query('lat') : null;
        $lng = $request->query('lng') !== null ? (float) $request->query('lng') : null;

        [$page, $perPage] = $this->pageParams($request, 20);
        $items = $this->recommendationService->getReadySoon($zoneId, $lat, $lng, $page * $perPage);

        return response()->json($this->paginate($items, $page, $perPage));
    }

    /**
     * @return array{0:int, 1:int}
     */
    private function pageParams(Request $request, int $defaultPerPage): array
    {
        $page = max(1, (int) $request->query('page', 1));
        $perPage = (int) $request->query('per_page', $defaultPerPage);
        $perPage = max(1, min(50, $perPage));

        return [$page, $perPage];
    }

    /**
     * @param  list<array<string,mixed>>  $items
     * @return array{data:list<array<string,mixed>>, meta:array<string,mixed>}
     */
    private function paginate(array $items, int $page, int $perPage): array
    {
        $total = count($items);
        $slice = array_slice($items, ($page - 1) * $perPage, $perPage);

        return [
            'data' => $slice,
            'meta' => [
                'page' => $page,
                'per_page' => $perPage,
                'count' => count($slice),
                'has_more' => $total > $page * $perPage,
            ],
        ];
    }
}
