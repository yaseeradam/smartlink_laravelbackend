<?php

namespace Tests\Feature;

use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaystackWebhookTest extends TestCase
{
    use RefreshDatabase;

    public function test_webhook_credits_wallet_idempotently(): void
    {
        config(['smartlink.paystack.webhook_secret' => 'test_secret']);

        $user = User::create([
            'full_name' => 'Buyer',
            'phone' => '08033333333',
            'email' => 'buyer2@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        /** @var WalletService $walletService */
        $walletService = app(WalletService::class);
        $wallet = $walletService->walletFor($user);

        $payload = [
            'event' => 'charge.success',
            'data' => [
                'id' => 12345,
                'status' => 'success',
                'reference' => 'paystack_ref_123',
                'amount' => 50000,
                'channel' => 'card',
                'paid_at' => now()->toISOString(),
                'metadata' => [
                    'user_id' => $user->id,
                    'purpose' => 'wallet_topup',
                ],
            ],
        ];

        $raw = json_encode($payload);
        $signature = hash_hmac('sha512', $raw, 'test_secret');

        $resp1 = $this
            ->withHeader('x-paystack-signature', $signature)
            ->postJson('/api/webhooks/paystack', $payload);

        $resp1->assertOk();

        $wallet->refresh();
        $this->assertSame('500.00', (string) $wallet->available_balance);

        // Duplicate webhook should be ignored (unique reference).
        $resp2 = $this
            ->withHeader('x-paystack-signature', $signature)
            ->postJson('/api/webhooks/paystack', $payload);

        $resp2->assertOk();

        $wallet->refresh();
        $this->assertSame('500.00', (string) $wallet->available_balance);

        $this->assertDatabaseCount('wallet_transactions', 1);
    }
}
