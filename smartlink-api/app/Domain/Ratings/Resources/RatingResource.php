<?php

namespace App\Domain\Ratings\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RatingResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Ratings\Models\Rating $rating */
        $rating = $this->resource;

        return [
            'id' => $rating->id,
            'order_id' => $rating->order_id,
            'rater_user_id' => $rating->rater_user_id,
            'ratee_user_id' => $rating->ratee_user_id,
            'ratee_type' => $rating->ratee_type->value,
            'stars' => $rating->stars,
            'comment' => $rating->comment,
            'created_at' => optional($rating->created_at)?->toISOString(),
        ];
    }
}

