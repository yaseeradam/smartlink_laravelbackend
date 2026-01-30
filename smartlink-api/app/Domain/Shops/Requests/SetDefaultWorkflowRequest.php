<?php

namespace App\Domain\Shops\Requests;

use Illuminate\Foundation\Http\FormRequest;

class SetDefaultWorkflowRequest extends FormRequest
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
            'workflow_id' => ['nullable', 'integer', 'exists:workflows,id'],
            'workflow_code' => ['nullable', 'string', 'max:100'],
        ];
    }
}

