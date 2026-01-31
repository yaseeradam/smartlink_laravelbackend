<?php

namespace App\Console;

use App\Domain\Recommendations\Jobs\AggregateDailyShopMetricsJob;
use App\Domain\Recommendations\Jobs\BuildCooccurrenceJob;
use App\Domain\Recommendations\Jobs\CalculateShopTrustMetricsJob;
use App\Domain\Recommendations\Jobs\UpdateUserPreferencesJob;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    /**
     * Define the application's command schedule.
     */
    protected function schedule(Schedule $schedule): void
    {
        $schedule->job(new AggregateDailyShopMetricsJob(now()->subDay()->toDateString()))->dailyAt('02:10');
        $schedule->job(new CalculateShopTrustMetricsJob(30))->dailyAt('02:20');
        $schedule->job(new BuildCooccurrenceJob(60))->dailyAt('02:30');
        $schedule->job(new UpdateUserPreferencesJob(null, 30))->dailyAt('03:00');

        // Freshen near-term metrics for trending.
        $schedule->job(new AggregateDailyShopMetricsJob(now()->toDateString()))->hourly();
    }

    /**
     * Register the commands for the application.
     */
    protected function commands(): void
    {
        $this->load(__DIR__ . '/Commands');

        require base_path('routes/console.php');
    }
}
