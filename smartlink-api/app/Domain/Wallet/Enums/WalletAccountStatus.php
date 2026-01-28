<?php

namespace App\Domain\Wallet\Enums;

enum WalletAccountStatus: string
{
    case Active = 'active';
    case Frozen = 'frozen';
}

