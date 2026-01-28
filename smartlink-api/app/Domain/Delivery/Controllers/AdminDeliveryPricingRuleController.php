<?php

namespace App\Domain\Delivery\Controllers;

use App\Domain\Delivery\Models\DeliveryPricingRule;
use App\Domain\Delivery\Requests\StoreDeliveryPricingRuleRequest;

class AdminDeliveryPricingRuleController
{
    public function index()
    {
        $rules = DeliveryPricingRule::query()
            ->orderBy('zone_id')
            ->orderBy('id')
            ->paginate(50);

        return response()->json($rules);
    }

    public function store(StoreDeliveryPricingRuleRequest $request)
    {
        $rule = DeliveryPricingRule::create($request->validated());

        return response()->json([
            'id' => $rule->id,
            'zone_id' => $rule->zone_id,
            'base_fee' => (string) $rule->base_fee,
            'max_distance_km' => $rule->max_distance_km !== null ? (string) $rule->max_distance_km : null,
            'rider_share_percent' => (string) $rule->rider_share_percent,
            'platform_fee_percent' => (string) $rule->platform_fee_percent,
        ], 201);
    }
}
