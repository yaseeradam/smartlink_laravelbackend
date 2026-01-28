<?php

namespace App\Domain\Notifications\Providers;

use App\Domain\Notifications\Contracts\PushProvider;
use Illuminate\Support\Facades\Log;

class LogPushProvider implements PushProvider
{
    public function send(array $deviceTokens, string $title, string $body, array $data = []): void
    {
        Log::info('Push notification (log driver)', [
            'device_tokens' => $deviceTokens,
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);
    }
}
