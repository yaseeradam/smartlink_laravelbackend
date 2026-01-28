<?php

namespace App\Domain\Escrow\Controllers;

use App\Domain\Escrow\Requests\TriggerPayoutRequest;
use App\Domain\Escrow\Services\PayoutService;

class AdminPayoutController
{
    public function __construct(private readonly PayoutService $payoutService)
    {
    }

    public function trigger(TriggerPayoutRequest $request)
    {
        $data = $request->validated();

        try {
            $result = $this->payoutService->triggerForSeller(
                (int) $data['seller_user_id'],
                $data['reference'] ?? null,
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json($result);
    }
}
