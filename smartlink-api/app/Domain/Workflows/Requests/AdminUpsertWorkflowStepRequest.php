<?php

namespace App\Domain\Workflows\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AdminUpsertWorkflowStepRequest extends FormRequest
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
            'step_key' => ['sometimes', 'required', 'string', 'max:100', 'regex:/^[a-z0-9_]+$/'],
            'title' => ['sometimes', 'required', 'string', 'max:255'],
            'sequence' => ['sometimes', 'required', 'integer', 'min:1', 'max:1000000'],
            'is_dispatch_trigger' => ['sometimes', 'required', 'boolean'],
            'is_terminal' => ['sometimes', 'required', 'boolean'],
        ];
    }
}

