<?php

namespace App\Domain\Orders\Models;

use App\Domain\Dispatch\Enums\DispatchPurpose;
use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Returns\Models\ReturnRequest;
use App\Domain\Cancellations\Models\Cancellation;
use App\Domain\Messaging\Models\Message;
use App\Domain\Disputes\Models\Dispute;
use App\Domain\Escrow\Models\EscrowHold;
use App\Domain\Orders\Enums\OrderKind;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderQuoteStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Enums\OrderWorkflowState;
use App\Domain\Products\Models\Product;
use App\Domain\Ratings\Models\Rating;
use App\Domain\Shops\Enums\ShopType;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use App\Domain\Workflows\Models\Workflow;
use App\Domain\Workflows\Models\WorkflowStep;
use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'subtotal_amount' => 'decimal:2',
        'delivery_fee_amount' => 'decimal:2',
        'rider_share_amount' => 'decimal:2',
        'platform_fee_amount' => 'decimal:2',
        'total_amount' => 'decimal:2',
        'status' => OrderStatus::class,
        'payment_status' => OrderPaymentStatus::class,
        'order_kind' => OrderKind::class,
        'service_type' => ShopType::class,
        'quoted_amount' => 'decimal:2',
        'quote_status' => OrderQuoteStatus::class,
        'quote_sent_at' => 'datetime',
        'quote_approved_at' => 'datetime',
        'workflow_state' => OrderWorkflowState::class,
        'workflow_started_at' => 'datetime',
        'workflow_completed_at' => 'datetime',
        'delivery_otp_required' => 'boolean',
        'delivery_otp_expires_at' => 'datetime',
        'delivery_otp_verified_at' => 'datetime',
    ];

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

    public function workflow()
    {
        return $this->belongsTo(Workflow::class);
    }

    public function workflowStep()
    {
        return $this->belongsTo(WorkflowStep::class, 'workflow_step_id');
    }

    public function workflowEvents()
    {
        return $this->hasMany(OrderWorkflowEvent::class)->orderBy('id');
    }
}
