<?php

namespace App\Domain\Admin\Services;

use App\Domain\Admin\Models\AdminActionLog;
use Illuminate\Http\Request;

class AdminAuditService
{
    /**
     * @param  array<string,mixed>|null  $oldState
     * @param  array<string,mixed>|null  $newState
     */
    public function log(
        int $adminUserId,
        string $actionType,
        string $entityType,
        ?int $entityId,
        string $reason,
        ?array $oldState,
        ?array $newState,
        Request $request,
    ): AdminActionLog {
        return AdminActionLog::create([
            'admin_user_id' => $adminUserId,
            'action_type' => $actionType,
            'entity_type' => $entityType,
            'entity_id' => $entityId,
            'old_state' => $oldState,
            'new_state' => $newState,
            'reason' => $reason,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'created_at' => now(),
        ]);
    }
}

