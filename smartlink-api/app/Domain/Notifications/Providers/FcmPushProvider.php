<?php

namespace App\Domain\Notifications\Providers;

use App\Domain\Notifications\Contracts\PushProvider;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmPushProvider implements PushProvider
{
    public function send(array $deviceTokens, string $title, string $body, array $data = []): void
    {
        $serverKey = (string) config('smartlink.push.fcm.server_key');
        $baseUrl = (string) config('smartlink.push.fcm.base_url', 'https://fcm.googleapis.com/fcm/send');

        if ($serverKey === '') {
            Log::warning('FCM server key is missing; skipping push.');
            return;
        }

        if ($deviceTokens === []) {
            return;
        }

        Http::withHeaders(['Authorization' => 'key='.$serverKey])
            ->asJson()
            ->post($baseUrl, [
                'registration_ids' => array_values($deviceTokens),
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => $data,
            ])
            ->throw();
    }
}
