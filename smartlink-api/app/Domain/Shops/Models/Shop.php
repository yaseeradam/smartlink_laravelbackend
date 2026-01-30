<?php

namespace App\Domain\Shops\Models;

use App\Domain\Products\Models\Product;
use App\Domain\Shops\Enums\ShopType;
use App\Domain\Shops\Enums\ShopVerificationPhase;
use App\Domain\Users\Models\User;
use App\Domain\Workflows\Models\Workflow;
use App\Domain\Zones\Models\Zone;
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
}
