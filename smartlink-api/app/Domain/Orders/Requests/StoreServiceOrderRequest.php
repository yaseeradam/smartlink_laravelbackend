<?php

namespace App\Domain\Orders\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreServiceOrderRequest extends FormRequest
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
            'shop_id' => ['required', 'integer', 'exists:shops,id'],
            'delivery_address_text' => ['required', 'string', 'max:255'],
            'service_type' => ['required', 'string', 'in:retail,food,repair,tailor,laundry,print'],
            'issue_description' => ['nullable', 'string', 'max:5000'],
        ];
    }
}

