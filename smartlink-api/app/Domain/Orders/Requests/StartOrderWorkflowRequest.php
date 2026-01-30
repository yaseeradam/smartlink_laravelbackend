<?php

namespace App\Domain\Orders\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StartOrderWorkflowRequest extends FormRequest
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
            'eta_min' => ['nullable', 'integer', 'min:0', 'max:1000000'],
            'eta_max' => ['nullable', 'integer', 'min:0', 'max:1000000'],
        ];
    }
}

