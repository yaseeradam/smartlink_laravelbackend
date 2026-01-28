<?php

namespace App\Domain\Zones\Enums;

enum ZoneStatus: string
{
    case Active = 'active';
    case Paused = 'paused';
}
