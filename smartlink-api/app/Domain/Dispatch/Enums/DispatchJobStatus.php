<?php

namespace App\Domain\Dispatch\Enums;

enum DispatchJobStatus: string
{
    case Pending = 'pending';
    case Broadcasting = 'broadcasting';
    case Assigned = 'assigned';
    case Expired = 'expired';
    case Cancelled = 'cancelled';
}

