<?php

namespace App\Domain\Riders\Enums;

enum RiderAvailabilityStatus: string
{
    case Offline = 'offline';
    case Available = 'available';
    case Busy = 'busy';
}

