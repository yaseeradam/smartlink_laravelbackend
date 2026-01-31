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

        $workflow = $order->relationLoaded('workflow') ? $order->workflow : null;
        $workflowStep = $order->relationLoaded('workflowStep') ? $order->workflowStep : null;

        return [
            'id' => $order->id,
            'buyer_user_id' => $order->buyer_user_id,
            'shop_id' => $order->shop_id,
            'zone_id' => $order->zone_id,
            'fulfillment_mode' => $order->fulfillment_mode?->value,
            'order_kind' => $order->order_kind?->value,
            'service_type' => $order->service_type?->value,
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
            'workflow' => $workflow ? [
                'code' => $workflow->code,
                'name' => $workflow->name,
                'is_active' => (bool) $workflow->is_active,
            ] : null,
            'workflow_state' => $order->workflow_state?->value,
            'workflow_step' => $workflowStep ? [
                'step_key' => $workflowStep->step_key,
                'title' => $workflowStep->title,
                'sequence' => (int) $workflowStep->sequence,
                'is_dispatch_trigger' => (bool) $workflowStep->is_dispatch_trigger,
                'is_terminal' => (bool) $workflowStep->is_terminal,
            ] : null,
            'workflow_eta_min' => $order->workflow_eta_min,
            'workflow_eta_max' => $order->workflow_eta_max,
            'workflow_started_at' => optional($order->workflow_started_at)?->toISOString(),
            'workflow_completed_at' => optional($order->workflow_completed_at)?->toISOString(),
            'workflow_timeline' => $this->whenLoaded('workflowEvents', function () use ($order) {
                return $order->workflowEvents->map(function ($event) {
                    return [
                        'from_step_key' => $event->fromStep?->step_key,
                        'from_step_title' => $event->fromStep?->title,
                        'to_step_key' => $event->toStep?->step_key,
                        'to_step_title' => $event->toStep?->title,
                        'changed_by_user_id' => $event->changed_by_user_id,
                        'created_at' => optional($event->created_at)?->toISOString(),
                    ];
                })->values();
            }),
            'quote' => [
                'issue_description' => $order->issue_description,
                'quoted_amount' => $order->quoted_amount !== null ? (string) $order->quoted_amount : null,
                'quote_status' => $order->quote_status?->value,
                'quote_sent_at' => optional($order->quote_sent_at)?->toISOString(),
                'quote_approved_at' => optional($order->quote_approved_at)?->toISOString(),
            ],
            'escrow' => $order->relationLoaded('escrowHold') && $order->escrowHold
                ? [
                    'status' => $order->escrowHold->status->value,
                    'hold_expires_at' => optional($order->escrowHold->hold_expires_at)?->toISOString(),
                ]
                : null,
            'shipment' => $this->whenLoaded('shipment', function () use ($order) {
                $shipment = $order->shipment;
                if (! $shipment) {
                    return null;
                }

                return [
                    'id' => $shipment->id,
                    'shipping_type' => $shipment->shipping_type->value,
                    'courier_name' => $shipment->courier_name,
                    'tracking_number' => $shipment->tracking_number,
                    'origin_state' => $shipment->origin_state,
                    'destination_state' => $shipment->destination_state,
                    'shipping_fee' => (string) $shipment->shipping_fee,
                    'status' => $shipment->status->value,
                    'proof_dropoff_url' => $shipment->proof_dropoff_url,
                    'proof_delivery_url' => $shipment->proof_delivery_url,
                    'eta_days_min' => $shipment->eta_days_min,
                    'eta_days_max' => $shipment->eta_days_max,
                    'created_at' => optional($shipment->created_at)?->toISOString(),
                    'updated_at' => optional($shipment->updated_at)?->toISOString(),
                ];
            }),
            'shipment_timeline' => $this->whenLoaded('shipment', function () use ($order) {
                $shipment = $order->shipment;
                if (! $shipment || ! $shipment->relationLoaded('timeline')) {
                    return null;
                }

                return $shipment->timeline->map(function ($e) {
                    return [
                        'status' => $e->status,
                        'changed_by_user_id' => $e->changed_by_user_id,
                        'meta' => $e->meta_json,
                        'created_at' => optional($e->created_at)?->toISOString(),
                    ];
                })->values();
            }),
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'created_at' => optional($order->created_at)?->toISOString(),
        ];
    }
}
