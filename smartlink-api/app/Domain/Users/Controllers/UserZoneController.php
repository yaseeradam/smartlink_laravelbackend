<?php

namespace App\Domain\Users\Controllers;

use App\Domain\Users\Requests\SetUserZoneRequest;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;

class UserZoneController
{
    public function store(SetUserZoneRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        /** @var Zone $zone */
        $zone = Zone::query()->where('id', $data['zone_id'])->where('is_active', true)->firstOrFail();

        $record = UserZone::updateOrCreate(
            ['user_id' => $user->id, 'type' => $data['type']],
            ['zone_id' => $zone->id],
        );

        return response()->json([
            'message' => 'Zone updated.',
            'user_zone' => [
                'id' => $record->id,
                'type' => $record->type,
                'zone_id' => $record->zone_id,
            ],
        ]);
    }
}

