<?php

namespace App\Domain\Workflows\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AdminUpsertWorkflowRequest extends FormRequest
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
            'code' => ['sometimes', 'required', 'string', 'max:100'],
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'is_active' => ['sometimes', 'required', 'boolean'],
        ];
    }
}

