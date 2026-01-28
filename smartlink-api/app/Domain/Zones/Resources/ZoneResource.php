<?php

namespace App\Domain\Zones\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ZoneResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Zones\Models\Zone $zone */
        $zone = $this->resource;

        return [
            'id' => $zone->id,
            'name' => $zone->name,
            'city' => $zone->city,
            'state' => $zone->state,
            'is_active' => (bool) $zone->is_active,
            'status' => $zone->status?->value ?? 'active',
        ];
    }
}
