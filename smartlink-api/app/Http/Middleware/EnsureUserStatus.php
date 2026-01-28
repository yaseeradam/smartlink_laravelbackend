<?php

namespace App\Http\Middleware;

use BackedEnum;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserStatus
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user) {
            $status = $user->status instanceof BackedEnum ? $user->status->value : (string) $user->status;

            if (in_array($status, ['suspended', 'banned'], true)) {
                return response()->json(['message' => 'Account is not active.'], 403);
            }
        }

        return $next($request);
    }
}

