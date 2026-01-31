<?php

namespace App\Domain\Shops\Models;

use App\Domain\Products\Models\Product;
use App\Domain\Shops\Enums\ShopShippingType;
use App\Domain\Shops\Enums\ShopType;
use App\Domain\Shops\Enums\ShopVerificationPhase;
use App\Domain\Users\Models\User;
use App\Domain\Workflows\Models\Workflow;
use App\Domain\Zones\Models\Zone;
use App\Domain\Recommendations\Models\ShopTag as RecommendationShopTag;
use App\Domain\Recommendations\Models\ShopTrustMetric;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Shop extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'is_verified' => 'boolean',
        'verification_phase' => ShopVerificationPhase::class,
        'shop_type' => ShopType::class,
        'is_open' => 'boolean',
        'operating_hours_json' => 'array',
        'latitude' => 'decimal:7',
        'longitude' => 'decimal:7',
        'shipping_type' => ShopShippingType::class,
        'is_deliverable_outside_state' => 'boolean',
    ];

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_user_id');
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function products()
    {
        return $this->hasMany(Product::class);
    }

    public function defaultWorkflow()
    {
        return $this->belongsTo(Workflow::class, 'default_workflow_id');
    }

    public function tags()
    {
        return $this->hasMany(RecommendationShopTag::class);
    }

    public function trustMetrics()
    {
        return $this->hasOne(ShopTrustMetric::class, 'shop_id');
    }
}
