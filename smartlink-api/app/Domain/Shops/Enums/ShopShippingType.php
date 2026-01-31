<?php

namespace App\Domain\Shops\Enums;

enum ShopShippingType: string
{
    case LocalRider = 'local_rider';
    case StateShipping = 'state_shipping';
    case NationShipping = 'nation_shipping';
}

