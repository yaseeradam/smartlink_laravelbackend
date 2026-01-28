<?php

namespace App\Domain\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class OtpVerifyRequest extends FormRequest
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
            'phone' => ['required', 'string', 'max:32', 'exists:users,phone'],
            'purpose' => ['required', 'string', Rule::in(['verify_phone'])],
            'code' => ['required', 'string', 'regex:/^[0-9]{6}$/'],
        ];
    }
}

