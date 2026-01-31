<?php

namespace App\Domain\Admin\Events;

use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcastNow;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class AdminShipmentUpdated implements ShouldBroadcastNow
{
    use Dispatchable;
    use SerializesModels;

    /**
     * @param  array<string,mixed>  $payload
     */
    public function __construct(public readonly int $orderId, public readonly array $payload)
    {
    }

    public function broadcastOn(): array
    {
        return [new PrivateChannel('private-order.'.$this->orderId)];
    }

    public function broadcastAs(): string
    {
        return 'AdminShipmentUpdated';
    }

    /**
     * @return array<string,mixed>
     */
    public function broadcastWith(): array
    {
        return $this->payload;
    }
}
