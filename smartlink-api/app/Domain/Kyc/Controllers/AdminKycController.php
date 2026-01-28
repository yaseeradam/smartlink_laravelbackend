<?php

namespace App\Domain\Kyc\Controllers;

use App\Domain\Kyc\Enums\KycStatus;
use App\Domain\Kyc\Enums\KycType;
use App\Domain\Kyc\Models\KycRequest;
use App\Domain\Kyc\Requests\AdminRejectKycRequest;
use App\Domain\Kyc\Resources\KycRequestResource;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Shops\Models\SellerBankAccount;
use App\Domain\Users\Enums\UserStatus;
use Illuminate\Support\Facades\DB;

class AdminKycController
{
    public function approve(KycRequest $kycRequest)
    {
        $admin = request()->user();

        $kyc = DB::transaction(function () use ($kycRequest, $admin) {
            $kycRequest->forceFill([
                'status' => KycStatus::Approved,
                'reviewed_by' => $admin->id,
                'reviewed_at' => now(),
                'rejection_reason' => null,
            ])->save();

            $user = $kycRequest->user()->lockForUpdate()->firstOrFail();
            $user->forceFill(['status' => UserStatus::Active])->save();

            if ($kycRequest->kyc_type === KycType::Seller) {
                SellerBankAccount::query()
                    ->where('seller_user_id', $user->id)
                    ->update(['verified_at' => now()]);

                $user->shop()?->update(['is_verified' => true]);
            }

            if ($kycRequest->kyc_type === KycType::Rider) {
                RiderAvailability::query()
                    ->where('rider_user_id', $user->id)
                    ->update(['status' => 'available', 'last_seen_at' => now()]);
            }

            return $kycRequest->fresh();
        });

        return new KycRequestResource($kyc);
    }

    public function reject(AdminRejectKycRequest $request, KycRequest $kycRequest)
    {
        $admin = $request->user();
        $data = $request->validated();

        $kyc = DB::transaction(function () use ($kycRequest, $admin, $data) {
            $kycRequest->forceFill([
                'status' => KycStatus::Rejected,
                'reviewed_by' => $admin->id,
                'reviewed_at' => now(),
                'rejection_reason' => $data['rejection_reason'],
            ])->save();

            return $kycRequest->fresh();
        });

        return new KycRequestResource($kyc);
    }
}

