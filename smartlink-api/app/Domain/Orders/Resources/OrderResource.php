<?php

namespace App\Domain\Orders\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Orders\Models\Order $order */
        $order = $this->resource;

        return [
            'id' => $order->id,
            'buyer_user_id' => $order->buyer_user_id,
            'shop_id' => $order->shop_id,
            'zone_id' => $order->zone_id,
            'subtotal_amount' => (string) $order->subtotal_amount,
            'delivery_fee_amount' => (string) $order->delivery_fee_amount,
            'rider_share_amount' => (string) $order->rider_share_amount,
            'platform_fee_amount' => (string) $order->platform_fee_amount,
            'total_amount' => (string) $order->total_amount,
            'status' => $order->status->value,
            'payment_status' => $order->payment_status->value,
            'delivery_address_text' => $order->delivery_address_text,
            'delivery_otp_required' => (bool) $order->delivery_otp_required,
            'delivery_otp_verified_at' => optional($order->delivery_otp_verified_at)?->toISOString(),
            'escrow' => $order->relationLoaded('escrowHold') && $order->escrowHold
                ? [
                    'status' => $order->escrowHold->status->value,
                    'hold_expires_at' => optional($order->escrowHold->hold_expires_at)?->toISOString(),
                ]
                : null,
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'created_at' => optional($order->created_at)?->toISOString(),
        ];
    }
}
