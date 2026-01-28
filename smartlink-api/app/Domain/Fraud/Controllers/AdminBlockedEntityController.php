<?php

namespace App\Domain\Fraud\Controllers;

use App\Domain\Fraud\Models\BlockedEntity;
use App\Domain\Fraud\Requests\StoreBlockedEntityRequest;

class AdminBlockedEntityController
{
    public function index()
    {
        $blocked = BlockedEntity::query()->orderByDesc('id')->paginate(50);

        return response()->json($blocked);
    }

    public function store(StoreBlockedEntityRequest $request)
    {
        $data = $request->validated();

        $record = BlockedEntity::firstOrCreate(
            ['type' => $data['type'], 'value' => $data['value']],
            ['reason' => $data['reason'] ?? null],
        );

        return response()->json([
            'id' => $record->id,
            'type' => $record->type->value,
            'value' => $record->value,
            'reason' => $record->reason,
        ], 201);
    }
}
