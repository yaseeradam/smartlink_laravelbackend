<?php

namespace App\Domain\Dispatch\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ManageRiderPoolRequest extends FormRequest
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
            'rider_user_id' => ['required', 'integer', 'exists:users,id'],
            'shop_id' => ['nullable', 'integer', 'exists:shops,id'],
        ];
    }
}
