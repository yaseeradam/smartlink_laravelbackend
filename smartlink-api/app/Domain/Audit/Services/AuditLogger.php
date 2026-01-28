<?php

namespace App\Domain\Audit\Services;

use App\Domain\Audit\Models\AuditLog;
use Illuminate\Database\Eloquent\Model;

class AuditLogger
{
    /**
     * @param  array<string, mixed>  $meta
     */
    public function log(
        ?int $actorUserId,
        string $action,
        ?Model $auditable = null,
        array $meta = [],
    ): void {
        $req = request();

        AuditLog::create([
            'actor_user_id' => $actorUserId,
            'action' => $action,
            'auditable_type' => $auditable ? $auditable::class : null,
            'auditable_id' => $auditable?->getKey(),
            'ip_address' => $req?->ip(),
            'user_agent' => $req?->userAgent(),
            'meta_json' => $meta === [] ? null : $meta,
        ]);
    }
}

