<?php

namespace App\Domain\Admin\Middleware;

use Closure;
use App\Domain\Admin\Models\AdminUser;
use Illuminate\Http\Request;

class EnsureAdminActive
{
    public function handle(Request $request, Closure $next)
    {
        $admin = $request->user('admin');
        if (! $admin || ! ($admin instanceof AdminUser) || ! $admin->is_active) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        return $next($request);
    }
}
