<?php

namespace App\Domain\Auth\Controllers;

use App\Domain\Auth\Requests\OtpSendRequest;
use App\Domain\Auth\Requests\OtpVerifyRequest;
use App\Domain\Auth\Services\OtpService;
use App\Domain\Notifications\Jobs\SendOtpJob;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Users\Resources\UserResource;
use Illuminate\Support\Facades\DB;

class OtpController
{
    public function send(OtpSendRequest $request, OtpService $otpService)
    {
        $data = $request->validated();

        /** @var User $user */
        $user = User::where('phone', $data['phone'])->firstOrFail();

        $code = $otpService->generateCode();
        $otpService->store($user->phone, $data['purpose'], $code);

        dispatch(new SendOtpJob($user->phone, $code, $otpService->ttlMinutes()));

        return response()->json(['message' => 'OTP sent.']);
    }

    public function verify(OtpVerifyRequest $request, OtpService $otpService)
    {
        $data = $request->validated();

        /** @var User $user */
        $user = User::where('phone', $data['phone'])->firstOrFail();

        if (! $otpService->verify($user->phone, $data['purpose'], $data['code'])) {
            return response()->json(['message' => 'Invalid or expired OTP.'], 422);
        }

        DB::transaction(function () use ($user): void {
            $user->forceFill(['phone_verified_at' => now()])->save();

            if ($user->role === UserRole::Buyer && $user->status === UserStatus::Pending) {
                $user->forceFill(['status' => UserStatus::Active])->save();
            }
        });

        $otpService->consume($user->phone, $data['purpose']);

        return new UserResource($user->fresh());
    }
}

