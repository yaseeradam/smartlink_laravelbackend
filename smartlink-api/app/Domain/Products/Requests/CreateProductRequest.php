<?php

namespace App\Domain\Products\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateProductRequest extends FormRequest
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
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:5000'],
            'price' => ['required', 'numeric', 'min:0.01'],
            'stock_qty' => ['required', 'integer', 'min:0'],
            'status' => ['nullable', 'string', Rule::in(['active', 'inactive', 'out_of_stock'])],
            'images' => ['nullable', 'array', 'max:5'],
            'images.*' => ['file', 'image', 'max:4096'],
        ];
    }
}

