<?php

namespace App\Domain\Orders\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreOrderRequest extends FormRequest
{
    protected function prepareForValidation(): void
    {
        $this->merge([
            'order_kind' => $this->input('order_kind', 'product'),
        ]);
    }

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
            'order_kind' => ['required', 'string', 'in:product,service'],
            'service_type' => ['required_if:order_kind,service', 'string', 'in:retail,food,repair,tailor,laundry,print'],
            'issue_description' => ['nullable', 'string', 'max:5000'],
            'items' => ['required_if:order_kind,product', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'integer', 'exists:products,id'],
            'items.*.qty' => ['required', 'integer', 'min:1'],
        ];
    }
}
