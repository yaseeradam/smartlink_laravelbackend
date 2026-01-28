<?php

namespace App\Domain\Webhooks\Controllers;

use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaystackWebhookController
{
    public function __construct(private readonly WalletService $walletService)
    {
    }

    public function handle(Request $request)
    {
        $secret = (string) config('smartlink.paystack.webhook_secret');
        $signature = (string) $request->header('x-paystack-signature', '');
        $payload = (string) $request->getContent();

        if ($secret === '' || $signature === '' || ! hash_equals(hash_hmac('sha512', $payload, $secret), $signature)) {
            return response()->json(['message' => 'Invalid signature.'], 401);
        }

        $event = (string) data_get($request->json()->all(), 'event', '');

        if ($event !== 'charge.success') {
            return response()->json(['message' => 'Ignored.']);
        }

        $data = $request->json('data');

        $status = (string) data_get($data, 'status', '');
        if ($status !== 'success') {
            return response()->json(['message' => 'Ignored.']);
        }

        $reference = (string) data_get($data, 'reference', '');
        $amountKobo = (int) data_get($data, 'amount', 0);
        $userId = (int) data_get($data, 'metadata.user_id', 0);

        if ($reference === '' || $amountKobo <= 0 || $userId <= 0) {
            Log::warning('Paystack webhook missing required fields', ['reference' => $reference, 'user_id' => $userId]);
            return response()->json(['message' => 'Ignored.']);
        }

        /** @var User|null $user */
        $user = User::query()->find($userId);
        if (! $user) {
            return response()->json(['message' => 'Ignored.']);
        }

        $wallet = $this->walletService->walletFor($user);
        $amount = $amountKobo / 100;

        $this->walletService->record(
            $wallet,
            WalletTransactionType::Topup,
            WalletTransactionDirection::In,
            $amount,
            $reference,
            relatedEntityType: 'paystack',
            relatedEntityId: (int) data_get($data, 'id', 0) ?: null,
            meta: [
                'event' => $event,
                'channel' => data_get($data, 'channel'),
                'paid_at' => data_get($data, 'paid_at'),
            ],
        );

        return response()->json(['message' => 'OK']);
    }
}

