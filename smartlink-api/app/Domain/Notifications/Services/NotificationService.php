<?php

namespace App\Domain\Notifications\Services;

use App\Domain\Notifications\Contracts\OtpProvider;
use App\Domain\Notifications\Contracts\PushProvider;
use App\Domain\Notifications\Events\UserNotificationEvent;
use App\Domain\Users\Models\User;
use App\Domain\Users\Models\UserDevice;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    public function __construct(
        private readonly OtpProvider $otpProvider,
        private readonly PushProvider $pushProvider,
    ) {
    }

    public function sendOtp(string $phone, string $code, int $ttlMinutes = 5): void
    {
        $message = "Your Smartlink OTP is {$code}. Expires in {$ttlMinutes} minutes.";

        $this->otpProvider->send($phone, $message);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function notifyUser(int $userId, string $title, string $body, array $data = [], bool $forcePush = false): void
    {
        event(new UserNotificationEvent($userId, [
            'title' => $title,
            'body' => $body,
            'data' => $data,
            'sent_at' => now()->toISOString(),
        ]));

        $tokens = $this->eligibleDeviceTokens($userId, $forcePush);
        if ($tokens === []) {
            return;
        }

        $this->pushProvider->send($tokens, $title, $body, $data);
    }

    /**
     * @param  array<string, mixed>  $data
     */
    public function notifyAdmins(string $title, string $body, array $data = []): void
    {
        $admins = User::query()->where('role', 'admin')->get(['id']);
        foreach ($admins as $admin) {
            $this->notifyUser((int) $admin->id, $title, $body, $data, true);
        }
    }

    public function sendDeliveryOtp(string $phone, string $code, int $ttlMinutes): void
    {
        $message = "Your Smartlink delivery OTP is {$code}. Expires in {$ttlMinutes} minutes.";

        $this->otpProvider->send($phone, $message);
    }

    /**
     * @return list<string>
     */
    private function eligibleDeviceTokens(int $userId, bool $forcePush): array
    {
        $devices = UserDevice::query()
            ->where('user_id', $userId)
            ->get(['device_token', 'last_seen_at']);

        if ($devices->isEmpty()) {
            return [];
        }

        if ($forcePush) {
            return $devices->pluck('device_token')->all();
        }

        $threshold = (int) config('smartlink.push.background_threshold_minutes', 5);
        $cutoff = now()->subMinutes($threshold);

        return $devices
            ->filter(function (UserDevice $device) use ($cutoff) {
                if (! $device->last_seen_at) {
                    return true;
                }

                return Carbon::parse($device->last_seen_at)->lessThan($cutoff);
            })
            ->pluck('device_token')
            ->all();
    }
}
