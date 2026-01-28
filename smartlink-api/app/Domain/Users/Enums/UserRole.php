<?php

namespace App\Domain\Users\Enums;

enum UserRole: string
{
    case Buyer = 'buyer';
    case Seller = 'seller';
    case Rider = 'rider';
    case Admin = 'admin';
}

