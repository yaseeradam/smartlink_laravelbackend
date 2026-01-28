<?php

namespace App\Domain\Zones\Controllers;

use App\Domain\Zones\Models\Zone;
use Illuminate\Support\Facades\Cache;

class AdminZoneController
{
    public function pause(Zone $zone)
    {
        $zone->forceFill(['status' => 'paused', 'is_active' => false])->save();
        Cache::forget('zones:active');

        return response()->json(['message' => 'Zone paused.', 'id' => $zone->id]);
    }

    public function resume(Zone $zone)
    {
        $zone->forceFill(['status' => 'active', 'is_active' => true])->save();
        Cache::forget('zones:active');

        return response()->json(['message' => 'Zone resumed.', 'id' => $zone->id]);
    }
}
