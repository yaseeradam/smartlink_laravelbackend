<?php

namespace App\Domain\Orders\Models;

use App\Domain\Dispatch\Enums\DispatchPurpose;
use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Returns\Models\ReturnRequest;
use App\Domain\Cancellations\Models\Cancellation;
use App\Domain\Messaging\Models\Message;
use App\Domain\Disputes\Models\Dispute;
use App\Domain\Escrow\Models\EscrowHold;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Products\Models\Product;
use App\Domain\Ratings\Models\Rating;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'subtotal_amount' => 'decimal:2',
            'delivery_fee_amount' => 'decimal:2',
            'rider_share_amount' => 'decimal:2',
            'platform_fee_amount' => 'decimal:2',
            'total_amount' => 'decimal:2',
            'status' => OrderStatus::class,
            'payment_status' => OrderPaymentStatus::class,
            'delivery_otp_required' => 'boolean',
            'delivery_otp_expires_at' => 'datetime',
            'delivery_otp_verified_at' => 'datetime',
        ];
    }

    public function buyer()
    {
        return $this->belongsTo(User::class, 'buyer_user_id');
    }

    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function statusHistory()
    {
        return $this->hasMany(OrderStatusHistory::class);
    }

    public function escrowHold()
    {
        return $this->hasOne(EscrowHold::class);
    }

    public function dispatchJob()
    {
        return $this->hasOne(DispatchJob::class)->where('purpose', DispatchPurpose::Delivery->value);
    }

    public function returnDispatchJob()
    {
        return $this->hasOne(DispatchJob::class)->where('purpose', DispatchPurpose::Return->value);
    }

    public function cancellation()
    {
        return $this->hasOne(Cancellation::class);
    }

    public function returnRequest()
    {
        return $this->hasOne(ReturnRequest::class, 'order_id');
    }

    public function messages()
    {
        return $this->hasMany(Message::class);
    }

    public function dispute()
    {
        return $this->hasOne(Dispute::class);
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }
}
