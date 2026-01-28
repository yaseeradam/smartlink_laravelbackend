<?php

namespace App\Domain\Kyc\Enums;

enum KycType: string
{
    case BuyerBasic = 'buyer_basic';
    case Seller = 'seller';
    case Rider = 'rider';
}

