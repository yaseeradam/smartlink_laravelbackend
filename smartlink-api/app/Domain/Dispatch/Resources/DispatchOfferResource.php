<?php

namespace App\Domain\Dispatch\Resources;

use App\Domain\Orders\Resources\OrderResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DispatchOfferResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Dispatch\Models\DispatchOffer $offer */
        $offer = $this->resource;

        return [
            'id' => $offer->id,
            'dispatch_job_id' => $offer->dispatch_job_id,
            'rider_user_id' => $offer->rider_user_id,
            'offer_status' => $offer->offer_status->value,
            'offered_at' => optional($offer->offered_at)?->toISOString(),
            'responded_at' => optional($offer->responded_at)?->toISOString(),
            'order' => $offer->relationLoaded('job') && $offer->job?->relationLoaded('order')
                ? new OrderResource($offer->job->order->loadMissing(['items', 'escrowHold']))
                : null,
        ];
    }
}

