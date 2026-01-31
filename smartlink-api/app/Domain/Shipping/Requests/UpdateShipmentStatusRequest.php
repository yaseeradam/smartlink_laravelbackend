<?php

namespace App\Domain\Shipping\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateShipmentStatusRequest extends FormRequest
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
            'status' => ['required', 'in:pending,packed,in_transit,out_for_delivery,delivered,failed'],
            'proof_delivery_url' => ['nullable', 'string', 'min:5', 'max:2048'],
        ];
    }
}
