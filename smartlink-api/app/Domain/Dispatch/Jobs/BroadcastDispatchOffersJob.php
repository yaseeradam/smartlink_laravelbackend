<?php

namespace App\Domain\Dispatch\Jobs;

use App\Domain\Dispatch\Services\DispatchService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class BroadcastDispatchOffersJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(public readonly int $dispatchJobId, public readonly string $mode)
    {
    }

    public function handle(DispatchService $dispatchService): void
    {
        $dispatchService->broadcastOffers($this->dispatchJobId, $this->mode);
    }
}

