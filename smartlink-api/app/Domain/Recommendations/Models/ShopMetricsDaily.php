<?php

namespace App\Domain\Recommendations\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ShopMetricsDaily extends Model
{
    use HasFactory;

    protected $table = 'shop_metrics_daily';

    protected $guarded = [];

    protected $casts = [
        'date' => 'date',
        'avg_rating' => 'decimal:3',
    ];
}
