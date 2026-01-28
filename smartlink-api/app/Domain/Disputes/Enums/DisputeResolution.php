<?php

namespace App\Domain\Disputes\Enums;

enum DisputeResolution: string
{
    case RefundBuyer = 'refund_buyer';
    case PaySeller = 'pay_seller';
    case PartialRefund = 'partial_refund';
    case PenalizeRider = 'penalize_rider';
    case PenalizeSeller = 'penalize_seller';
}

