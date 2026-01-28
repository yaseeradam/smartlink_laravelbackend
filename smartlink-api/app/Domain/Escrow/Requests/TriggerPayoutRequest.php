<?php

namespace App\Domain\Escrow\Requests;

use Illuminate\Foundation\Http\FormRequest;

class TriggerPayoutRequest extends FormRequest
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
            'seller_user_id' => ['required', 'integer', 'exists:users,id'],
            'reference' => ['nullable', 'string', 'max:128'],
        ];
    }
}
