<?php

namespace App\Domain\Delivery\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreDeliveryPricingRuleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'zone_id' => ['required', 'integer', 'exists:zones,id'],
            'base_fee' => ['required', 'numeric', 'min:0'],
            'max_distance_km' => ['nullable', 'numeric', 'min:0'],
            'rider_share_percent' => ['required', 'numeric', 'min:0', 'max:100'],
            'platform_fee_percent' => ['required', 'numeric', 'min:0', 'max:100'],
        ];
    }
}
