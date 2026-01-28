<?php

namespace App\Domain\Escrow\Services;

use App\Domain\Escrow\Enums\PayoutStatus;
use App\Domain\Escrow\Models\Payout;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PayoutService
{
    /**
     * @return array{reference:string, total:float, count:int}
     */
    public function triggerForSeller(int $sellerUserId, ?string $reference = null): array
    {
        $reference = $reference ?: 'manual:'.Str::uuid()->toString();

        $existing = Payout::query()
            ->where('seller_user_id', $sellerUserId)
            ->where('provider_ref', $reference)
            ->exists();

        if ($existing) {
            $total = (float) Payout::query()
                ->where('seller_user_id', $sellerUserId)
                ->where('provider_ref', $reference)
                ->sum('amount');

            $count = Payout::query()
                ->where('seller_user_id', $sellerUserId)
                ->where('provider_ref', $reference)
                ->count();

            return [
                'reference' => $reference,
                'total' => $total,
                'count' => $count,
            ];
        }

        $pending = Payout::query()
            ->where('seller_user_id', $sellerUserId)
            ->where('status', PayoutStatus::Pending)
            ->lockForUpdate()
            ->get();

        $total = (float) $pending->sum('amount');
        $minThreshold = (float) config('smartlink.payouts.minimum_threshold', 0);

        if ($pending->isEmpty() || $total < $minThreshold) {
            throw new \RuntimeException('Payout threshold not met.');
        }

        DB::transaction(function () use ($pending, $reference) {
            foreach ($pending as $payout) {
                $payout->forceFill([
                    'status' => PayoutStatus::Paid,
                    'provider_ref' => $reference,
                ])->save();
            }
        });

        return [
            'reference' => $reference,
            'total' => $total,
            'count' => $pending->count(),
        ];
    }
}
