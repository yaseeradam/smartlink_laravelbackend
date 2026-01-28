<?php

namespace App\Domain\Delivery\Services;

use App\Domain\Delivery\Models\DeliveryPricingRule;

class DeliveryFeeService
{
    /**
     * @return array{delivery_fee: float, rider_share: float, platform_fee: float, rule_id: int|null}
     */
    public function calculateForZone(int $zoneId, ?float $distanceKm = null): array
    {
        $ruleQuery = DeliveryPricingRule::query()->where('zone_id', $zoneId);

        if ($distanceKm !== null) {
            $ruleQuery->where(function ($query) use ($distanceKm) {
                $query->whereNull('max_distance_km')
                    ->orWhere('max_distance_km', '>=', $distanceKm);
            })->orderByRaw('max_distance_km is null');
        }

        /** @var DeliveryPricingRule|null $rule */
        $rule = $ruleQuery->orderBy('id')->first();

        $baseFee = $rule?->base_fee !== null
            ? (float) $rule->base_fee
            : (float) config('smartlink.delivery_fees.default_base_fee', 0);

        $riderSharePercent = $rule?->rider_share_percent !== null
            ? (float) $rule->rider_share_percent
            : (float) config('smartlink.delivery_fees.default_rider_share_percent', 70);

        $platformFeePercent = $rule?->platform_fee_percent !== null
            ? (float) $rule->platform_fee_percent
            : (float) config('smartlink.delivery_fees.default_platform_fee_percent', 30);

        $riderShare = round($baseFee * $riderSharePercent / 100, 2);
        $platformFee = round($baseFee * $platformFeePercent / 100, 2);

        return [
            'delivery_fee' => $baseFee,
            'rider_share' => $riderShare,
            'platform_fee' => $platformFee,
            'rule_id' => $rule?->id,
        ];
    }
}
