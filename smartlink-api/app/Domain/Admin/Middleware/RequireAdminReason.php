<?php

namespace App\Domain\Admin\Middleware;

use Closure;
use Illuminate\Http\Request;

class RequireAdminReason
{
    public function handle(Request $request, Closure $next)
    {
        if (! in_array($request->method(), ['POST', 'PUT', 'PATCH', 'DELETE'], true)) {
            return $next($request);
        }

        // Auth endpoints should not require a mutation reason.
        if (str_starts_with($request->path(), 'api/admin/auth')) {
            return $next($request);
        }

        $reason = $request->input('reason');
        if (! is_string($reason) || trim($reason) === '') {
            return response()->json(['message' => 'reason is required.'], 422);
        }

        return $next($request);
    }
}

