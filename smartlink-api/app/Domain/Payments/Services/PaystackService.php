<?php

namespace App\Domain\Payments\Services;

use App\Domain\Users\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class PaystackService
{
    /**
     * @return array{authorization_url: string, reference: string}
     */
    public function initializeTopup(User $user, float $amount): array
    {
        $secretKey = config('smartlink.paystack.secret_key');
        $baseUrl = rtrim((string) config('smartlink.paystack.base_url', 'https://api.paystack.co'), '/');

        if (! $secretKey) {
            throw new \RuntimeException('PAYSTACK_SECRET_KEY is not configured.');
        }

        if (! $user->email) {
            throw new \RuntimeException('Email is required to initialize Paystack payments.');
        }

        $reference = (string) Str::uuid();
        $amountKobo = (int) round($amount * 100);

        $response = Http::baseUrl($baseUrl)
            ->withToken($secretKey)
            ->asJson()
            ->post('/transaction/initialize', [
                'email' => $user->email,
                'amount' => $amountKobo,
                'reference' => $reference,
                'metadata' => [
                    'user_id' => $user->id,
                    'purpose' => 'wallet_topup',
                ],
            ])
            ->throw()
            ->json();

        $authUrl = (string) data_get($response, 'data.authorization_url');
        $ref = (string) data_get($response, 'data.reference', $reference);

        if ($authUrl === '' || $ref === '') {
            throw new \RuntimeException('Paystack initialize response is missing authorization_url/reference.');
        }

        return [
            'authorization_url' => $authUrl,
            'reference' => $ref,
        ];
    }
}

