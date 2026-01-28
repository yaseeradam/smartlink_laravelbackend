<?php

namespace App\Domain\Wallet\Requests;

use Illuminate\Foundation\Http\FormRequest;

class InitiateTopupRequest extends FormRequest
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
            'amount' => ['required', 'numeric', 'min:100'],
        ];
    }
}

