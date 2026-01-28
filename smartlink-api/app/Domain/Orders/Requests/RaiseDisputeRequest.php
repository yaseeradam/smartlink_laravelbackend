<?php

namespace App\Domain\Orders\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class RaiseDisputeRequest extends FormRequest
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
            'reason' => ['required', 'string', Rule::in(['wrong_item', 'damaged_item', 'not_delivered', 'other'])],
            'description' => ['nullable', 'string', 'max:2000'],
        ];
    }
}

