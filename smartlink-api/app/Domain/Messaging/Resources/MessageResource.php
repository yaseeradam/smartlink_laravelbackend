<?php

namespace App\Domain\Messaging\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MessageResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Messaging\Models\Message $message */
        $message = $this->resource;

        return [
            'id' => $message->id,
            'order_id' => $message->order_id,
            'sender_user_id' => $message->sender_user_id,
            'message_text' => $message->message_text,
            'created_at' => optional($message->created_at)?->toISOString(),
        ];
    }
}
