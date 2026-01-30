<?php

namespace App\Domain\Orders\Enums;

enum OrderKind: string
{
    case Product = 'product';
    case Service = 'service';
}

