<?php

namespace App\Domain\Returns\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ReturnResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Returns\Models\ReturnRequest $return */
        $return = $this->resource;

        return [
            'id' => $return->id,
            'order_id' => $return->order_id,
            'status' => $return->status->value,
            'reason' => $return->reason,
            'created_at' => optional($return->created_at)?->toISOString(),
        ];
    }
}
