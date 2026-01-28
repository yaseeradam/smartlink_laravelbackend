<?php

namespace App\Domain\Wallet\Enums;

enum WalletTransactionDirection: string
{
    case In = 'in';
    case Out = 'out';
}

