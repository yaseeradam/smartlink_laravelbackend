<?php

namespace App\Domain\Users\Controllers;

use App\Domain\Fraud\Services\FraudService;
use App\Domain\Users\Models\UserDevice;
use App\Domain\Users\Requests\StoreUserDeviceRequest;

class UserDeviceController
{
    public function store(StoreUserDeviceRequest $request, FraudService $fraudService)
    {
        $data = $request->validated();
        $user = $request->user();

        $fraudService->ensureDeviceAllowed((string) $data['device_token']);

        $device = UserDevice::updateOrCreate(
            ['device_token' => $data['device_token']],
            [
                'user_id' => $user->id,
                'platform' => $data['platform'],
                'last_seen_at' => now(),
            ],
        );

        return response()->json([
            'id' => $device->id,
            'device_token' => $device->device_token,
            'platform' => $device->platform->value,
            'last_seen_at' => optional($device->last_seen_at)?->toISOString(),
        ]);
    }
}
