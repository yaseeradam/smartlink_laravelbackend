<?php

namespace App\Domain\Shipping\Requests;

use Illuminate\Foundation\Http\FormRequest;

class MarkDroppedOffRequest extends FormRequest
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
            'tracking_number' => ['required', 'string', 'min:3', 'max:120'],
            'proof_dropoff_url' => ['required', 'string', 'min:5', 'max:2048'],
        ];
    }
}

