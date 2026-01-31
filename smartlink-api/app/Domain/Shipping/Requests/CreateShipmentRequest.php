<?php

namespace App\Domain\Shipping\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateShipmentRequest extends FormRequest
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
            'shipping_type' => ['nullable', 'in:seller_handled,partner'],
            'courier_name' => ['required', 'string', 'min:2', 'max:120'],
            'shipping_fee' => ['required', 'numeric', 'min:0'],
            'eta_days_min' => ['required', 'integer', 'min:0', 'max:60'],
            'eta_days_max' => ['required', 'integer', 'min:0', 'max:60', 'gte:eta_days_min'],
        ];
    }
}

