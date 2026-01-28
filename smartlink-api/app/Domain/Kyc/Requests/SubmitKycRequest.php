<?php

namespace App\Domain\Kyc\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SubmitKycRequest extends FormRequest
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
            'kyc_type' => ['required', 'string', Rule::in(['buyer_basic', 'seller', 'rider'])],

            'rc_number' => ['required_if:kyc_type,seller', 'string', 'max:64'],
            'bank_name' => ['required_if:kyc_type,seller', 'string', 'max:128'],
            'account_number' => ['required_if:kyc_type,seller', 'string', 'max:32'],
            'account_name' => ['required_if:kyc_type,seller', 'string', 'max:128'],

            'vehicle_type' => ['required_if:kyc_type,rider', 'string', Rule::in(['bike', 'car', 'tricycle'])],
            'plate_number' => ['nullable', 'string', 'max:32'],

            'documents' => ['nullable', 'array', 'max:10'],
            'documents.*' => ['file', 'max:10240'],
            'doc_types' => ['nullable', 'array'],
            'doc_types.*' => ['string', 'max:64'],
        ];
    }
}

