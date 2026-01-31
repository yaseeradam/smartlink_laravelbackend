<?php

namespace App\Domain\Shipping\Enums;

enum ShipmentShippingType: string
{
    case SellerHandled = 'seller_handled';
    case Partner = 'partner';
}

