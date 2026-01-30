<?php

namespace App\Domain\Workflows\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AdminUpsertWorkflowTransitionRequest extends FormRequest
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
            'from_step_key' => ['required', 'string', 'max:100', 'regex:/^[a-z0-9_]+$/'],
            'to_step_key' => ['required', 'string', 'max:100', 'regex:/^[a-z0-9_]+$/'],
        ];
    }
}

