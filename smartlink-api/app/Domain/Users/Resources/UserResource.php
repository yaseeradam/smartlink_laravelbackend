<?php

namespace App\Domain\Users\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Users\Models\User $user */
        $user = $this->resource;

        return [
            'id' => $user->id,
            'full_name' => $user->full_name,
            'phone' => $user->phone,
            'email' => $user->email,
            'role' => $user->role->value,
            'status' => $user->status->value,
            'phone_verified_at' => optional($user->phone_verified_at)?->toISOString(),
            'email_verified_at' => optional($user->email_verified_at)?->toISOString(),
            'created_at' => optional($user->created_at)?->toISOString(),
        ];
    }
}

