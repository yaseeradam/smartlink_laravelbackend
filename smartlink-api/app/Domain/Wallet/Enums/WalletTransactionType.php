<?php

namespace App\Domain\Wallet\Enums;

enum WalletTransactionType: string
{
    case Topup = 'topup';
    case Debit = 'debit';
    case Credit = 'credit';
    case Hold = 'hold';
    case Release = 'release';
    case Refund = 'refund';
    case Fee = 'fee';
}

