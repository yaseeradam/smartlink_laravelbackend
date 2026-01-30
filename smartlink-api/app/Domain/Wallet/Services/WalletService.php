<?php

namespace App\Domain\Wallet\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletAccountStatus;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Models\WalletAccount;
use App\Domain\Wallet\Models\WalletTransaction;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class WalletService
{
    public function __construct(private readonly AuditLogger $auditLogger)
    {
    }

    public function requireVerifiedForWallet(User $user): void
    {
        if (!$user->hasVerifiedPhone()) {
            throw new \RuntimeException('Phone verification required.');
        }
    }

    public function walletFor(User $user): WalletAccount
    {
        return WalletAccount::firstOrCreate(
            ['user_id' => $user->id],
            [
                'currency' => (string) config('smartlink.currency', 'NGN'),
                'available_balance' => 0,
                'status' => WalletAccountStatus::Active,
            ],
        );
    }

    /**
     * Idempotent ledger writer (unique reference).
     */
    public function record(
        WalletAccount $walletAccount,
        WalletTransactionType $type,
        WalletTransactionDirection $direction,
        float $amount,
        string $reference,
        ?string $relatedEntityType = null,
        ?int $relatedEntityId = null,
        array $meta = [],
    ): WalletTransaction {
        return DB::transaction(function () use ($walletAccount, $type, $direction, $amount, $reference, $relatedEntityType, $relatedEntityId, $meta) {
            $existing = WalletTransaction::query()->where('reference', $reference)->first();
            if ($existing) {
                return $existing;
            }

            /** @var WalletAccount $locked */
            $locked = WalletAccount::query()->whereKey($walletAccount->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === WalletAccountStatus::Frozen) {
                throw new \RuntimeException('Wallet is frozen.');
            }

            $amount = round($amount, 2);
            if ($amount <= 0) {
                throw new \InvalidArgumentException('Amount must be positive.');
            }

            $newBalance = $locked->available_balance;

            if ($direction === WalletTransactionDirection::In) {
                $newBalance = $locked->available_balance + $amount;
            } else {
                if ($locked->available_balance < $amount) {
                    throw new \RuntimeException('Insufficient wallet balance.');
                }
                $newBalance = $locked->available_balance - $amount;
            }

            try {
                $tx = WalletTransaction::create([
                    'wallet_account_id' => $locked->id,
                    'type' => $type,
                    'direction' => $direction,
                    'amount' => $amount,
                    'reference' => $reference,
                    'related_entity_type' => $relatedEntityType,
                    'related_entity_id' => $relatedEntityId,
                    'meta_json' => $meta === [] ? null : $meta,
                ]);
            } catch (QueryException $e) {
                $existing = WalletTransaction::query()->where('reference', $reference)->first();
                if ($existing) {
                    return $existing;
                }
                throw $e;
            }

            $locked->forceFill(['available_balance' => $newBalance])->save();

            $this->auditLogger->log(
                isset($meta['actor_user_id']) ? (int) $meta['actor_user_id'] : null,
                'wallet.transaction.created',
                $tx,
                [
                    'wallet_account_id' => $locked->id,
                    'type' => $type->value,
                    'direction' => $direction->value,
                    'amount' => $amount,
                    'reference' => $reference,
                    'related_entity_type' => $relatedEntityType,
                    'related_entity_id' => $relatedEntityId,
                ],
            );

            return $tx;
        });
    }
}
