<?php

namespace App\Domain\Orders\Enums;

enum OrderPaymentStatus: string
{
    case Pending = 'pending';
    case Paid = 'paid';
    case Refunded = 'refunded';
}

