<?php

namespace App\Domain\Admin\Controllers;

use App\Domain\Admin\Models\AdminUser;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminAuthController
{
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string', 'min:6'],
            'device_name' => ['nullable', 'string', 'max:80'],
        ]);

        /** @var AdminUser|null $admin */
        $admin = AdminUser::query()->where('email', $data['email'])->first();
        if (! $admin || ! Hash::check((string) $data['password'], (string) $admin->password_hash)) {
            return response()->json(['message' => 'Invalid credentials.'], 422);
        }

        if (! $admin->is_active) {
            return response()->json(['message' => 'Account is disabled.'], 403);
        }

        $admin->forceFill(['last_login_at' => now()])->save();

        $token = $admin->createToken((string) ($data['device_name'] ?? 'admin'))->plainTextToken;

        return response()->json([
            'token' => $token,
            'admin' => [
                'id' => $admin->id,
                'name' => $admin->name,
                'email' => $admin->email,
                'is_active' => (bool) $admin->is_active,
                'last_login_at' => optional($admin->last_login_at)?->toISOString(),
            ],
        ]);
    }

    public function me(Request $request)
    {
        $admin = $request->user('admin');

        return response()->json([
            'id' => $admin->id,
            'name' => $admin->name,
            'email' => $admin->email,
            'is_active' => (bool) $admin->is_active,
            'last_login_at' => optional($admin->last_login_at)?->toISOString(),
        ]);
    }

    public function logout(Request $request)
    {
        $admin = $request->user('admin');
        $admin?->currentAccessToken()?->delete();

        return response()->json(['message' => 'Logged out.']);
    }
}

