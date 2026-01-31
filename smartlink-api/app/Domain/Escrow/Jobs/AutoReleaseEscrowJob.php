<?php

namespace App\Domain\Escrow\Jobs;

use App\Domain\Disputes\Enums\DisputeStatus;
use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Escrow\Models\EscrowHold;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Orders\Enums\OrderFulfillmentMode;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Shipping\Enums\ShipmentStatus;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class AutoReleaseEscrowJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(public readonly int $escrowHoldId)
    {
    }

    public function handle(EscrowService $escrowService): void
    {
        /** @var EscrowHold|null $hold */
        $hold = EscrowHold::query()->with(['order.dispute', 'order.shipment'])->find($this->escrowHoldId);
        if (! $hold) {
            return;
        }

        if ($hold->status !== EscrowStatus::Held) {
            return;
        }

        if (! $hold->hold_expires_at || now()->lessThan($hold->hold_expires_at)) {
            return;
        }

        $order = $hold->order;
        if (! $order || $order->status !== OrderStatus::Delivered) {
            return;
        }

        if ($order->fulfillment_mode === OrderFulfillmentMode::Shipping) {
            $shipment = $order->shipment;
            if (! $shipment || $shipment->status !== ShipmentStatus::Delivered) {
                return;
            }
        }

        if ($order->dispute && in_array($order->dispute->status, [DisputeStatus::Open, DisputeStatus::UnderReview], true)) {
            return;
        }

        $escrowService->release($hold, null);
    }
}
