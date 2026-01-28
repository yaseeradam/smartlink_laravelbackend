<?php

namespace App\Domain\Returns\Models;

use App\Domain\Orders\Models\Order;
use App\Domain\Returns\Enums\ReturnStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReturnRequest extends Model
{
    use HasFactory;

    protected $table = 'returns';

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'status' => ReturnStatus::class,
        ];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
