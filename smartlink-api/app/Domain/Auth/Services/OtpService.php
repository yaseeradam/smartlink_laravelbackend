<?php

namespace App\Domain\Auth\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class OtpService
{
    public function generateCode(): string
    {
        return (string) random_int(100000, 999999);
    }

    public function ttlMinutes(): int
    {
        return 5;
    }

    public function store(string $phone, string $purpose, string $code): void
    {
        Cache::put(
            $this->cacheKey($phone, $purpose),
            [
                'hash' => Hash::make($code),
                'attempts' => 0,
                'nonce' => Str::uuid()->toString(),
            ],
            now()->addMinutes($this->ttlMinutes()),
        );
    }

    public function verify(string $phone, string $purpose, string $code): bool
    {
        $key = $this->cacheKey($phone, $purpose);
        $payload = Cache::get($key);

        if (! is_array($payload) || ! isset($payload['hash'])) {
            return false;
        }

        $attempts = (int) ($payload['attempts'] ?? 0);
        if ($attempts >= 5) {
            Cache::forget($key);
            return false;
        }

        $ok = Hash::check($code, (string) $payload['hash']);

        if (! $ok) {
            $payload['attempts'] = $attempts + 1;
            Cache::put($key, $payload, now()->addMinutes($this->ttlMinutes()));
        }

        return $ok;
    }

    public function consume(string $phone, string $purpose): void
    {
        Cache::forget($this->cacheKey($phone, $purpose));
    }

    private function cacheKey(string $phone, string $purpose): string
    {
        return 'otp:'.preg_replace('/\\s+/', '', $phone).':'.$purpose;
    }
}

