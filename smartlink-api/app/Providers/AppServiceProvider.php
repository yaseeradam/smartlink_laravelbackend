<?php

namespace App\Providers;

use App\Domain\Notifications\Contracts\OtpProvider;
use App\Domain\Notifications\Contracts\PushProvider;
use App\Domain\Notifications\Providers\FcmPushProvider;
use App\Domain\Notifications\Providers\LogPushProvider;
use App\Domain\Notifications\Providers\LogOtpProvider;
use App\Domain\Notifications\Providers\SendchampOtpProvider;
use App\Domain\Notifications\Providers\TermiiOtpProvider;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\RateLimiter;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(OtpProvider::class, function () {
            return match (config('smartlink.otp.driver')) {
                'termii' => $this->app->make(TermiiOtpProvider::class),
                'sendchamp' => $this->app->make(SendchampOtpProvider::class),
                default => $this->app->make(LogOtpProvider::class),
            };
        });

        $this->app->bind(PushProvider::class, function () {
            return match (config('smartlink.push.driver')) {
                'fcm' => $this->app->make(FcmPushProvider::class),
                default => $this->app->make(LogPushProvider::class),
            };
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('auth', function (Request $request) {
            $key = $request->ip().'|'.(string) $request->input('phone', $request->input('email', ''));

            return Limit::perMinute(10)->by($key);
        });

        RateLimiter::for('otp', function (Request $request) {
            $key = 'otp|'.$request->ip().'|'.(string) $request->input('phone', '');

            return Limit::perMinute(5)->by($key);
        });
    }
}
