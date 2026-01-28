<?php

namespace App\Domain\Disputes\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DisputeResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Disputes\Models\Dispute $dispute */
        $dispute = $this->resource;

        return [
            'id' => $dispute->id,
            'order_id' => $dispute->order_id,
            'raised_by_user_id' => $dispute->raised_by_user_id,
            'reason' => $dispute->reason->value,
            'description' => $dispute->description,
            'status' => $dispute->status->value,
            'resolution' => $dispute->resolution?->value,
            'created_at' => optional($dispute->created_at)?->toISOString(),
        ];
    }
}

