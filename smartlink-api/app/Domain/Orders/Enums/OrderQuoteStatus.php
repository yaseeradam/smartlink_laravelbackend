<?php

namespace App\Domain\Orders\Enums;

enum OrderQuoteStatus: string
{
    case None = 'none';
    case Sent = 'sent';
    case Approved = 'approved';
    case Rejected = 'rejected';
}

