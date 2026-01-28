<?php

namespace App\Domain\Wallet\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WalletTransactionResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Wallet\Models\WalletTransaction $tx */
        $tx = $this->resource;

        return [
            'id' => $tx->id,
            'type' => $tx->type->value,
            'direction' => $tx->direction->value,
            'amount' => (string) $tx->amount,
            'reference' => $tx->reference,
            'meta' => $tx->meta_json,
            'created_at' => optional($tx->created_at)?->toISOString(),
        ];
    }
}

