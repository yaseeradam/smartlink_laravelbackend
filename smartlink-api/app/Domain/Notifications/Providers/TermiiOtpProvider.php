<?php

namespace App\Domain\Notifications\Providers;

use App\Domain\Notifications\Contracts\OtpProvider;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;

class TermiiOtpProvider implements OtpProvider
{
    /**
     * @throws RequestException
     */
    public function send(string $phone, string $message): void
    {
        $apiKey = config('smartlink.otp.termii.api_key');
        $senderId = config('smartlink.otp.sender_id', 'Smartlink');

        if (! $apiKey) {
            throw new \RuntimeException('TERMII_API_KEY is not configured.');
        }

        $baseUrl = rtrim((string) config('smartlink.otp.termii.base_url'), '/');

        Http::baseUrl($baseUrl)
            ->asJson()
            ->post('/api/sms/send', [
                'to' => $phone,
                'from' => $senderId,
                'sms' => $message,
                'type' => 'plain',
                'channel' => 'generic',
                'api_key' => $apiKey,
            ])
            ->throw();
    }
}

