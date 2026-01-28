<?php

namespace App\Domain\Disputes\Enums;

enum DisputeReason: string
{
    case WrongItem = 'wrong_item';
    case DamagedItem = 'damaged_item';
    case NotDelivered = 'not_delivered';
    case Other = 'other';
}

