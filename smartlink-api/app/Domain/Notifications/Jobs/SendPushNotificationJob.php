<?php

namespace App\Domain\Notifications\Jobs;

use App\Domain\Notifications\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendPushNotificationJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    /**
     * @param  array<string, mixed>  $data
     */
    public function __construct(
        public readonly int $userId,
        public readonly string $title,
        public readonly string $body,
        public readonly array $data = [],
        public readonly bool $forcePush = false,
    ) {
    }

    public function handle(NotificationService $notificationService): void
    {
        $notificationService->notifyUser(
            $this->userId,
            $this->title,
            $this->body,
            $this->data,
            $this->forcePush,
        );
    }
}
