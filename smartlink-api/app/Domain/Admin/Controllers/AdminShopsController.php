<?php

namespace App\Domain\Admin\Controllers;

use App\Domain\Admin\Services\AdminAuditService;
use App\Domain\Shops\Models\Shop;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminShopsController
{
    public function __construct(private readonly AdminAuditService $audit)
    {
    }

    public function index()
    {
        return Shop::query()->latest('id')->paginate(30);
    }

    public function verify(Request $request, Shop $shop)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $updated = DB::transaction(function () use ($request, $shop, $admin, $reason) {
            /** @var Shop $locked */
            $locked = Shop::query()->whereKey($shop->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();
            $locked->forceFill(['is_verified' => true])->save();
            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'shop.verify',
                entityType: 'shop',
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

    public function suspend(Request $request, Shop $shop)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $updated = DB::transaction(function () use ($request, $shop, $admin, $reason) {
            /** @var Shop $locked */
            $locked = Shop::query()->whereKey($shop->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();
            $locked->forceFill(['status' => 'inactive'])->save();
            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'shop.suspend',
                entityType: 'shop',
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

    public function unsuspend(Request $request, Shop $shop)
    {
        $admin = $request->user('admin');
        $reason = (string) $request->input('reason');

        $updated = DB::transaction(function () use ($request, $shop, $admin, $reason) {
            /** @var Shop $locked */
            $locked = Shop::query()->whereKey($shop->id)->lockForUpdate()->firstOrFail();

            $old = $locked->toArray();
            $locked->forceFill(['status' => 'active'])->save();
            $new = $locked->fresh()->toArray();

            $this->audit->log(
                adminUserId: (int) $admin->id,
                actionType: 'shop.unsuspend',
                entityType: 'shop',
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

