<?php

namespace App\Domain\Wallet\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WalletAccountResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Wallet\Models\WalletAccount $wallet */
        $wallet = $this->resource;

        return [
            'id' => $wallet->id,
            'currency' => $wallet->currency,
            'available_balance' => (string) $wallet->available_balance,
            'status' => $wallet->status->value,
            'created_at' => optional($wallet->created_at)?->toISOString(),
        ];
    }
}

