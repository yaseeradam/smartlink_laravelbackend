<?php

namespace App\Domain\Zones\Controllers;

use App\Domain\Zones\Models\Zone;
use App\Domain\Zones\Resources\ZoneResource;
use Illuminate\Support\Facades\Cache;

class ZoneController
{
    public function index()
    {
        $zones = Cache::remember('zones:active', 300, function () {
            return Zone::query()
                ->where('is_active', true)
                ->where('status', 'active')
                ->orderBy('state')
                ->orderBy('city')
                ->orderBy('name')
                ->get();
        });

        return ZoneResource::collection($zones);
    }
}
