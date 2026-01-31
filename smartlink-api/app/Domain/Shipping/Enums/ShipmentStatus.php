<?php

namespace App\Domain\Shipping\Enums;

enum ShipmentStatus: string
{
    case Pending = 'pending';
    case Packed = 'packed';
    case DroppedOff = 'dropped_off';
    case InTransit = 'in_transit';
    case OutForDelivery = 'out_for_delivery';
    case Delivered = 'delivered';
    case Confirmed = 'confirmed';
    case Failed = 'failed';
}

