<?php

namespace App\Domain\Shops\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateShopRequest extends FormRequest
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
            'shop_name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:2000'],
            'zone_id' => ['required', 'integer', 'exists:zones,id'],
            'address_text' => ['required', 'string', 'max:255'],
        ];
    }
}

