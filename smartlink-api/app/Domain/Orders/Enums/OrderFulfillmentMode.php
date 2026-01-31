<?php

namespace App\Domain\Orders\Enums;

enum OrderFulfillmentMode: string
{
    case LocalRider = 'local_rider';
    case Shipping = 'shipping';
}

