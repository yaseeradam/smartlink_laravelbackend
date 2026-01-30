<?php

namespace App\Domain\Dispatch\Policies;

use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Models\User;

class DispatchJobPolicy
{
    public function view(User $user, DispatchJob $dispatchJob): bool
    {
        if ($user->role === UserRole::Admin) {
            return true;
        }

        if ($user->role === UserRole::Seller) {
            return (int) ($dispatchJob->shop?->seller_user_id ?? 0) === (int) $user->id;
        }

        if ($user->role === UserRole::Rider) {
            return (int) ($dispatchJob->assigned_rider_user_id ?? 0) === (int) $user->id;
        }

        return false;
    }
}
