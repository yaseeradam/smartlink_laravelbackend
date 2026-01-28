<?php

namespace App\Domain\Auth\Controllers;

use App\Domain\Auth\Requests\LoginRequest;
use App\Domain\Auth\Requests\RegisterRequest;
use App\Domain\Auth\Services\OtpService;
use App\Domain\Fraud\Services\FraudService;
use App\Domain\Notifications\Jobs\SendOtpJob;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Users\Resources\UserResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AuthController
{
    public function register(RegisterRequest $request, OtpService $otpService, FraudService $fraudService)
    {
        $data = $request->validated();
        $fraudService->ensurePhoneAllowed((string) $data['phone']);

        /** @var User $user */
        $user = DB::transaction(function () use ($data): User {
            return User::create([
                'full_name' => $data['full_name'],
                'phone' => $data['phone'],
                'email' => $data['email'] ?? null,
                'password' => $data['password'],
                'role' => UserRole::from($data['role'] ?? UserRole::Buyer->value),
                'status' => UserStatus::Pending,
            ]);
        });

        if (! $user->hasVerifiedPhone()) {
            $code = $otpService->generateCode();
            $otpService->store($user->phone, 'verify_phone', $code);
            dispatch(new SendOtpJob($user->phone, $code, $otpService->ttlMinutes()));
        }

        $token = $user->createToken((string) ($data['device_name'] ?? 'mobile'))->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => new UserResource($user),
        ], 201);
    }

    public function login(LoginRequest $request)
    {
        $data = $request->validated();

        $user = User::query()
            ->when(isset($data['phone']), fn ($q) => $q->where('phone', $data['phone']))
            ->when(! isset($data['phone']) && isset($data['email']), fn ($q) => $q->where('email', $data['email']))
            ->first();

        if (! $user || ! Hash::check((string) $data['password'], (string) $user->password)) {
            return response()->json(['message' => 'Invalid credentials.'], 422);
        }

        try {
            app(FraudService::class)->ensurePhoneAllowed((string) $user->phone);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 403);
        }

        if (in_array($user->status->value, ['suspended', 'banned'], true)) {
            return response()->json(['message' => 'Account is not active.'], 403);
        }

        $token = $user->createToken((string) ($data['device_name'] ?? 'mobile'))->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => new UserResource($user),
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json(['message' => 'Logged out.']);
    }

    public function me(Request $request)
    {
        return new UserResource($request->user());
    }
}
