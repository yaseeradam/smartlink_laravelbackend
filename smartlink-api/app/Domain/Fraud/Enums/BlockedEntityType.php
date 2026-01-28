<?php

namespace App\Domain\Fraud\Enums;

enum BlockedEntityType: string
{
    case Phone = 'phone';
    case Device = 'device';
}
