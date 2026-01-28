<?php

namespace App\Providers;

use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Dispatch\Policies\DispatchJobPolicy;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Policies\OrderPolicy;
use App\Domain\Products\Models\Product;
use App\Domain\Products\Policies\ProductPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * @var array<class-string, class-string>
     */
    protected $policies = [
        Order::class => OrderPolicy::class,
        Product::class => ProductPolicy::class,
        DispatchJob::class => DispatchJobPolicy::class,
    ];

    public function boot(): void
    {
        $this->registerPolicies();
    }
}

