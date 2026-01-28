<?php

namespace App\Domain\Escrow\Enums;

enum PayoutProvider: string
{
    case Paystack = 'paystack';
    case Flutterwave = 'flutterwave';
}

