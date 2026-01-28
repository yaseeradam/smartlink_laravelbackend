<?php

namespace App\Domain\Wallet\Controllers;

use App\Domain\Payments\Services\PaystackService;
use App\Domain\Wallet\Requests\InitiateTopupRequest;
use App\Domain\Wallet\Resources\WalletAccountResource;
use App\Domain\Wallet\Resources\WalletTransactionResource;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Http\Request;

class WalletController
{
    public function __construct(
        private readonly WalletService $walletService,
        private readonly PaystackService $paystackService,
    ) {
    }

    public function show(Request $request)
    {
        $user = $request->user();

        $this->walletService->requireVerifiedForWallet($user);

        $wallet = $this->walletService->walletFor($user);

        return new WalletAccountResource($wallet);
    }

    public function transactions(Request $request)
    {
        $user = $request->user();

        $this->walletService->requireVerifiedForWallet($user);

        $wallet = $this->walletService->walletFor($user);

        $items = $wallet->transactions()
            ->latest('id')
            ->paginate(50);

        return WalletTransactionResource::collection($items);
    }

    public function initiateTopup(InitiateTopupRequest $request)
    {
        $user = $request->user();

        $this->walletService->requireVerifiedForWallet($user);

        $data = $request->validated();

        $init = $this->paystackService->initializeTopup($user, (float) $data['amount']);

        return response()->json([
            'authorization_url' => $init['authorization_url'],
            'reference' => $init['reference'],
        ]);
    }
}

