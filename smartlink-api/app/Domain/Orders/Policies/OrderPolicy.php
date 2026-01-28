<?php

namespace App\Domain\Orders\Policies;

use App\Domain\Orders\Models\Order;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Models\User;

class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        if ($user->role === UserRole::Admin) {
            return true;
        }

        if ($user->role === UserRole::Buyer) {
            return (int) $order->buyer_user_id === (int) $user->id;
        }

        if ($user->role === UserRole::Seller) {
            return (int) $order->shop_id === (int) ($user->shop?->id ?? 0);
        }

        if ($user->role === UserRole::Rider) {
            return (int) ($order->dispatchJob?->assigned_rider_user_id ?? 0) === (int) $user->id;
        }

        return false;
    }

    public function dispatch(User $user, Order $order): bool
    {
        return $user->role === UserRole::Seller
            && (int) $order->shop_id === (int) ($user->shop?->id ?? 0);
    }

    public function confirmDelivery(User $user, Order $order): bool
    {
        return $user->role === UserRole::Buyer
            && (int) $order->buyer_user_id === (int) $user->id;
    }

    public function raiseDispute(User $user, Order $order): bool
    {
        return $this->confirmDelivery($user, $order);
    }

    public function cancel(User $user, Order $order): bool
    {
        if ($user->role === UserRole::Admin) {
            return true;
        }

        if ($user->role === UserRole::Buyer) {
            return (int) $order->buyer_user_id === (int) $user->id;
        }

        if ($user->role === UserRole::Seller) {
            return (int) $order->shop_id === (int) ($user->shop?->id ?? 0);
        }

        if ($user->role === UserRole::Rider) {
            return (int) ($order->dispatchJob?->assigned_rider_user_id ?? 0) === (int) $user->id;
        }

        return false;
    }
}
