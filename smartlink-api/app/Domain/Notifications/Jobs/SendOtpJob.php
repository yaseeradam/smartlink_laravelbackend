<?php

namespace App\Domain\Notifications\Jobs;

use App\Domain\Notifications\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendOtpJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(
        public readonly string $phone,
        public readonly string $code,
        public readonly int $ttlMinutes = 5,
    ) {
    }

    public function handle(NotificationService $notificationService): void
    {
        $notificationService->sendOtp($this->phone, $this->code, $this->ttlMinutes);
    }
}

