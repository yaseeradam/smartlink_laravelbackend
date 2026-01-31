<?php

namespace App\Domain\Recommendations\Controllers;

use App\Domain\Recommendations\Jobs\LogUserEventJob;
use App\Domain\Recommendations\Models\UserFavorite;
use App\Domain\Shops\Models\Shop;
use Illuminate\Http\Request;

class FavoriteShopController
{
    public function store(Request $request, Shop $shop)
    {
        $user = $request->user();

        if (! $shop->is_verified || $shop->status !== 'active') {
            return response()->json(['message' => 'Not found.'], 404);
        }

        UserFavorite::query()->firstOrCreate([
            'user_id' => $user->id,
            'shop_id' => $shop->id,
        ]);

        dispatch(new LogUserEventJob([
            'user_id' => $user->id,
            'session_id' => null,
            'zone_id' => (int) $shop->zone_id,
            'event_type' => 'favorite_shop',
            'entity_type' => 'shop',
            'entity_id' => (int) $shop->id,
            'query_text' => null,
            'meta_json' => null,
        ]));

        return response()->json(['message' => 'favorited']);
    }

    public function destroy(Request $request, Shop $shop)
    {
        $user = $request->user();

        UserFavorite::query()
            ->where('user_id', $user->id)
            ->where('shop_id', $shop->id)
            ->delete();

        return response()->json(['message' => 'unfavorited']);
    }

    public function index(Request $request)
    {
        $user = $request->user();
        $zoneId = $request->query('zone_id');

        $favorites = UserFavorite::query()
            ->where('user_id', $user->id)
            ->when($zoneId, function ($q) use ($zoneId) {
                $q->whereHas('shop', fn ($sq) => $sq->where('zone_id', (int) $zoneId));
            })
            ->latest('id')
            ->paginate(50);

        return response()->json($favorites);
    }
}

