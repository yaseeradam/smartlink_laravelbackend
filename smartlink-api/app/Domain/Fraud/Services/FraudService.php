<?php

namespace App\Domain\Fraud\Services;

use App\Domain\Disputes\Enums\DisputeResolution;
use App\Domain\Disputes\Models\Dispute;
use App\Domain\Fraud\Enums\BlockedEntityType;
use App\Domain\Fraud\Models\BlockedEntity;
use App\Domain\Users\Models\User;

class FraudService
{
    public function ensurePhoneAllowed(string $phone): void
    {
        $blocked = BlockedEntity::query()
            ->where('type', BlockedEntityType::Phone->value)
            ->where('value', $phone)
            ->exists();

        if ($blocked) {
            throw new \RuntimeException('Phone number is blocked.');
        }
    }

    public function ensureDeviceAllowed(string $deviceToken): void
    {
        $blocked = BlockedEntity::query()
            ->where('type', BlockedEntityType::Device->value)
            ->where('value', $deviceToken)
            ->exists();

        if ($blocked) {
            throw new \RuntimeException('Device is blocked.');
        }
    }

    public function checkNewAccountOrderLimit(User $user, float $orderTotal): void
    {
        $maxAmount = (float) config('smartlink.fraud.new_account_max_order_amount', 0);
        $maxDays = (int) config('smartlink.fraud.new_account_age_days', 0);

        if ($maxAmount <= 0 || $maxDays <= 0) {
            return;
        }

        if ($user->created_at && $user->created_at->greaterThan(now()->subDays($maxDays)) && $orderTotal > $maxAmount) {
            throw new \RuntimeException('Order exceeds limit for new accounts.');
        }
    }

    public function recordDisputeStrike(User $buyer): void
    {
        $threshold = (int) config('smartlink.fraud.dispute_abuse_threshold', 0);
        if ($threshold <= 0) {
            return;
        }

        $count = Dispute::query()
            ->where('raised_by_user_id', $buyer->id)
            ->where('status', 'resolved')
            ->where('resolution', DisputeResolution::PaySeller->value)
            ->count();

        if ($count >= $threshold) {
            BlockedEntity::firstOrCreate(
                ['type' => BlockedEntityType::Phone, 'value' => $buyer->phone],
                ['reason' => 'Repeated dispute abuse'],
            );
        }
    }
}
