<?php

namespace App\Domain\Notifications\Providers;

use App\Domain\Notifications\Contracts\OtpProvider;
use Illuminate\Support\Facades\Log;

class LogOtpProvider implements OtpProvider
{
    public function send(string $phone, string $message): void
    {
        Log::info('OTP (log driver)', [
            'phone' => $phone,
            'message' => $message,
        ]);
    }
}

