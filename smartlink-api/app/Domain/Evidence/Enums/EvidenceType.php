<?php

namespace App\Domain\Evidence\Enums;

enum EvidenceType: string
{
    case PickupVideo = 'pickup_video';
    case DeliveryPhoto = 'delivery_photo';
}

