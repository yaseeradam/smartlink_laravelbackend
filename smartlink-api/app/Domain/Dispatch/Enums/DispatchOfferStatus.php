<?php

namespace App\Domain\Dispatch\Enums;

enum DispatchOfferStatus: string
{
    case Sent = 'sent';
    case Seen = 'seen';
    case Accepted = 'accepted';
    case Declined = 'declined';
    case Expired = 'expired';
}

