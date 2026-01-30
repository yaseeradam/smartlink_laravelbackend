<?php

namespace App\Domain\Orders\Policies;

use App\Domain\Orders\Models\Order;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Models\User;

class OrderPolicy
{
    private function sellerOwnsOrder(User $user, Order $order): bool
    {
        return (int) ($order->shop?->seller_user_id ?? 0) === (int) $user->id;
    }

    public function view(User $user, Order $order): bool
    {
        if ($user->role === UserRole::Admin) {
            return true;
        }

        if ($user->role === UserRole::Buyer) {
            return (int) $order->buyer_user_id === (int) $user->id;
        }

        if ($user->role === UserRole::Seller) {
            return $this->sellerOwnsOrder($user, $order);
        }

        if ($user->role === UserRole::Rider) {
            return (int) ($order->dispatchJob?->assigned_rider_user_id ?? 0) === (int) $user->id;
        }

        return false;
    }

    public function dispatch(User $user, Order $order): bool
    {
        return $user->role === UserRole::Seller
            && $this->sellerOwnsOrder($user, $order);
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
            return $this->sellerOwnsOrder($user, $order);
        }

        if ($user->role === UserRole::Rider) {
            return (int) ($order->dispatchJob?->assigned_rider_user_id ?? 0) === (int) $user->id;
        }

        return false;
    }

    public function manageWorkflow(User $user, Order $order): bool
    {
        return $user->role === UserRole::Seller && $this->sellerOwnsOrder($user, $order);
    }

    public function sendQuote(User $user, Order $order): bool
    {
        return $this->manageWorkflow($user, $order);
    }

    public function approveQuote(User $user, Order $order): bool
    {
        return $user->role === UserRole::Buyer
            && (int) $order->buyer_user_id === (int) $user->id;
    }
}
