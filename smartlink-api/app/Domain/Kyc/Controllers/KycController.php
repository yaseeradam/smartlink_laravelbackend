<?php

namespace App\Domain\Kyc\Controllers;

use App\Domain\Kyc\Enums\KycType;
use App\Domain\Kyc\Requests\SubmitKycRequest;
use App\Domain\Kyc\Resources\KycRequestResource;
use App\Domain\Kyc\Services\KycService;
use Illuminate\Http\Request;

class KycController
{
    public function __construct(private readonly KycService $kycService)
    {
    }

    public function submit(SubmitKycRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        $type = KycType::from($data['kyc_type']);

        $meta = collect($data)->only([
            'rc_number',
            'bank_name',
            'account_number',
            'account_name',
            'vehicle_type',
            'plate_number',
        ])->filter(fn ($v) => $v !== null)->all();

        try {
            $kyc = $this->kycService->submit(
                $user,
                $type,
                $meta,
                $request->file('documents', []),
                $data['doc_types'] ?? [],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new KycRequestResource($kyc);
    }

    public function status(Request $request)
    {
        $user = $request->user();

        $requests = $user->kycRequests()->latest('id')->get();

        return KycRequestResource::collection($requests);
    }
}

