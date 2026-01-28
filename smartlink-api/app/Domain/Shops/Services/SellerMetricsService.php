<?php

namespace App\Domain\Shops\Services;

use App\Domain\Disputes\Models\Dispute;
use App\Domain\Orders\Models\Order;
use Carbon\Carbon;

class SellerMetricsService
{
    /**
     * @return array<string, mixed>
     */
    public function forSellerShop(int $shopId): array
    {
        $today = Carbon::today();

        $todayOrdersCount = Order::query()
            ->where('shop_id', $shopId)
            ->whereDate('created_at', $today)
            ->count();

        $todayRevenue = Order::query()
            ->where('shop_id', $shopId)
            ->whereDate('created_at', $today)
            ->whereIn('status', ['delivered', 'confirmed'])
            ->sum('subtotal_amount');

        $totalOrders = Order::query()->where('shop_id', $shopId)->count();
        $successfulOrders = Order::query()
            ->where('shop_id', $shopId)
            ->whereIn('status', ['delivered', 'confirmed'])
            ->count();

        $disputes = Dispute::query()
            ->whereHas('order', fn ($q) => $q->where('shop_id', $shopId))
            ->count();

        $deliverySuccessRate = $totalOrders > 0 ? round(($successfulOrders / $totalOrders) * 100, 2) : 0;
        $disputeRate = $totalOrders > 0 ? round(($disputes / $totalOrders) * 100, 2) : 0;

        return [
            'today_orders_count' => $todayOrdersCount,
            'today_revenue' => (string) number_format((float) $todayRevenue, 2, '.', ''),
            'delivery_success_rate' => $deliverySuccessRate,
            'dispute_rate' => $disputeRate,
        ];
    }
}
