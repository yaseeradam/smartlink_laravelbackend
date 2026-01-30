<?php

namespace App\Domain\Shops\Enums;

enum ShopType: string
{
    case Retail = 'retail';
    case Food = 'food';
    case Repair = 'repair';
    case Tailor = 'tailor';
    case Laundry = 'laundry';
    case Print = 'print';
}

