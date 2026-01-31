<?php

namespace App\Domain\Admin\Controllers;

use App\Domain\Admin\Services\AdminAuditService;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminUsersController
{
    public function __construct(private readonly AdminAuditService $audit)
    {
    }

    public function index()
    {
        return User::query()->latest('id')->paginate(30);
    }

    public function suspend(Request $request, User $user)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $updated = DB::transaction(function () use ($request, $user, $admin, $reason) {
            /** @var User $locked */
            $locked = User::query()->whereKey($user->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();
            $locked->forceFill(['status' => UserStatus::Suspended])->save();
            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'user.suspend',
                entityType: 'user',
                entityId: (int) $locked->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $locked->fresh();
        });

        return response()->json(['data' => $updated]);
    }

    public function unsuspend(Request $request, User $user)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $updated = DB::transaction(function () use ($request, $user, $admin, $reason) {
            /** @var User $locked */
            $locked = User::query()->whereKey($user->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();
            $locked->forceFill(['status' => UserStatus::Active])->save();
            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'user.unsuspend',
                entityType: 'user',
                entityId: (int) $locked->id,
                reason: $reason,
                oldState: $old,
                newState: $new,
                request: $request,
            );

            return $locked->fresh();
        });

        return response()->json(['data' => $updated]);
    }
}

