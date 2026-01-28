<?php

namespace App\Domain\Kyc\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class KycRequestResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Kyc\Models\KycRequest $kyc */
        $kyc = $this->resource;

        return [
            'id' => $kyc->id,
            'user_id' => $kyc->user_id,
            'kyc_type' => $kyc->kyc_type->value,
            'status' => $kyc->status->value,
            'submitted_at' => optional($kyc->submitted_at)?->toISOString(),
            'reviewed_by' => $kyc->reviewed_by,
            'reviewed_at' => optional($kyc->reviewed_at)?->toISOString(),
            'rejection_reason' => $kyc->rejection_reason,
            'meta' => $kyc->meta_json,
        ];
    }
}

