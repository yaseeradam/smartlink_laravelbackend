<?php

namespace App\Domain\Dispatch\Enums;

enum DispatchPurpose: string
{
    case Delivery = 'delivery';
    case Return = 'return';
}
