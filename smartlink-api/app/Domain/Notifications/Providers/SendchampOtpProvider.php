<?php

namespace App\Domain\Notifications\Providers;

use App\Domain\Notifications\Contracts\OtpProvider;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;

class SendchampOtpProvider implements OtpProvider
{
    /**
     * @throws RequestException
     */
    public function send(string $phone, string $message): void
    {
        $apiKey = config('smartlink.otp.sendchamp.api_key');
        $senderId = config('smartlink.otp.sender_id', 'Smartlink');

        if (! $apiKey) {
            throw new \RuntimeException('SENDCHAMP_API_KEY is not configured.');
        }

        $baseUrl = rtrim((string) config('smartlink.otp.sendchamp.base_url'), '/');

        Http::baseUrl($baseUrl)
            ->withToken($apiKey)
            ->asJson()
            ->post('/sms/send', [
                'to' => $phone,
                'message' => $message,
                'sender_name' => $senderId,
                'route' => 'sms',
            ])
            ->throw();
    }
}

