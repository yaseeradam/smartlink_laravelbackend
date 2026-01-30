<?php

namespace App\Domain\Orders\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SendOrderQuoteRequest extends FormRequest
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
            'quoted_amount' => ['required', 'numeric', 'min:0.01'],
            'eta_min' => ['nullable', 'integer', 'min:0', 'max:1000000'],
            'eta_max' => ['nullable', 'integer', 'min:0', 'max:1000000'],
        ];
    }
}

