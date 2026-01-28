<?php

namespace App\Domain\Orders\Enums;

enum OrderStatus: string
{
    case Placed = 'placed';
    case Paid = 'paid';
    case AcceptedBySeller = 'accepted_by_seller';
    case Dispatching = 'dispatching';
    case AssignedToRider = 'assigned_to_rider';
    case PickedUp = 'picked_up';
    case Delivered = 'delivered';
    case Confirmed = 'confirmed';
    case Cancelled = 'cancelled';
    case Disputed = 'disputed';
}

