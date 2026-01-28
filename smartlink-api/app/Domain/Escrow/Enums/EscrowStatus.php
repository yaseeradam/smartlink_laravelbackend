<?php

namespace App\Domain\Escrow\Enums;

enum EscrowStatus: string
{
    case Held = 'held';
    case Released = 'released';
    case Frozen = 'frozen';
    case Refunded = 'refunded';
}

