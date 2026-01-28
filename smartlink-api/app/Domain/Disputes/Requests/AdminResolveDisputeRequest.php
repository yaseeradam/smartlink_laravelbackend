<?php

namespace App\Domain\Disputes\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AdminResolveDisputeRequest extends FormRequest
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
            'resolution' => ['required', 'string', Rule::in([
                'refund_buyer',
                'pay_seller',
                'partial_refund',
                'penalize_rider',
                'penalize_seller',
            ])],
            'partial_refund_amount' => ['nullable', 'numeric', 'min:0.01'],
        ];
    }
}

