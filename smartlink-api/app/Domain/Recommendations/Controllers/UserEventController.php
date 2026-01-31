<?php

namespace App\Domain\Recommendations\Controllers;

use App\Domain\Recommendations\Jobs\LogUserEventJob;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class UserEventController
{
    public function store(Request $request)
    {
        $data = $request->validate([
            'zone_id' => ['required', 'integer', 'exists:zones,id'],
            'session_id' => ['nullable', 'string', 'max:100'],
            'event_type' => ['required', 'string', Rule::in([
                'view_shop',
                'view_product',
                'search',
                'add_to_cart',
                'start_checkout',
                'place_order',
                'rate',
                'favorite_shop',
            ])],
            'entity_type' => ['nullable', 'string', Rule::in(['shop', 'product', 'category'])],
            'entity_id' => ['nullable', 'integer', 'min:1'],
            'query_text' => ['nullable', 'string', 'max:5000'],
            'meta_json' => ['nullable', 'array'],
        ]);

        $user = $request->user();

        dispatch(new LogUserEventJob([
            'user_id' => $user?->id,
            'session_id' => $data['session_id'] ?? null,
            'zone_id' => (int) $data['zone_id'],
            'event_type' => (string) $data['event_type'],
            'entity_type' => $data['entity_type'] ?? null,
            'entity_id' => isset($data['entity_id']) ? (int) $data['entity_id'] : null,
            'query_text' => $data['query_text'] ?? null,
            'meta_json' => $data['meta_json'] ?? null,
        ]));

        return response()->json(['message' => 'ok']);
    }
}

