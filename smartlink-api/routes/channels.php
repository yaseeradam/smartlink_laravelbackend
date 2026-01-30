<?php

use Illuminate\Support\Facades\Broadcast;
use App\Domain\Orders\Models\Order;

Broadcast::channel('user.{userId}', function ($user, int $userId) {
    return (int) $user->id === (int) $userId;
});

Broadcast::channel('order.{orderId}', function ($user, int $orderId) {
    /** @var Order|null $order */
    $order = Order::query()->with(['shop', 'dispatchJob'])->find($orderId);
    if (! $order) {
        return false;
    }

    if (($user->role?->value ?? null) === 'admin') {
        return true;
    }

    if (($user->role?->value ?? null) === 'buyer') {
        return (int) $order->buyer_user_id === (int) $user->id;
    }

    if (($user->role?->value ?? null) === 'seller') {
        return (int) ($order->shop?->seller_user_id ?? 0) === (int) $user->id;
    }

    if (($user->role?->value ?? null) === 'rider') {
        return (int) ($order->dispatchJob?->assigned_rider_user_id ?? 0) === (int) $user->id;
    }

    return false;
});
