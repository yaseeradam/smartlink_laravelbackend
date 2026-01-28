<?php

namespace App\Domain\Ratings\Controllers;

use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Ratings\Models\Rating;
use App\Domain\Ratings\Requests\StoreRatingRequest;
use App\Domain\Ratings\Resources\RatingResource;
use Illuminate\Support\Facades\DB;

class RatingController
{
    public function store(StoreRatingRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        /** @var Order $order */
        $order = Order::query()->with(['shop', 'dispatchJob'])->whereKey($data['order_id'])->firstOrFail();

        if ((int) $order->buyer_user_id !== (int) $user->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if ($order->status !== OrderStatus::Confirmed) {
            return response()->json(['message' => 'Ratings are allowed after confirmation.'], 422);
        }

        $rateeUserId = null;
        if ($data['ratee_type'] === 'seller') {
            $rateeUserId = (int) $order->shop->seller_user_id;
        } else {
            $rateeUserId = (int) ($order->dispatchJob?->assigned_rider_user_id ?? 0);
            if (! $rateeUserId) {
                return response()->json(['message' => 'No rider assigned to this order.'], 422);
            }
        }

        $rating = DB::transaction(function () use ($data, $user, $order, $rateeUserId) {
            $existing = Rating::query()
                ->where('order_id', $order->id)
                ->where('rater_user_id', $user->id)
                ->where('ratee_type', $data['ratee_type'])
                ->first();

            if ($existing) {
                return $existing;
            }

            return Rating::create([
                'order_id' => $order->id,
                'rater_user_id' => $user->id,
                'ratee_user_id' => $rateeUserId,
                'ratee_type' => $data['ratee_type'],
                'stars' => $data['stars'],
                'comment' => $data['comment'] ?? null,
            ]);
        });

        return new RatingResource($rating);
    }
}

