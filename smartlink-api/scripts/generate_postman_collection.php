<?php

/**
 * Generates a Postman Collection from `php artisan route:list --json`.
 *
 * Usage:
 *   php scripts/generate_postman_collection.php
 *
 * Output:
 *   postman/Smartlink.postman_collection.json
 */

declare(strict_types=1);

function run(string $cmd): string
{
    $out = shell_exec($cmd);
    if (! is_string($out) || trim($out) === '') {
        throw new RuntimeException("Command failed or returned empty output: {$cmd}");
    }

    return $out;
}

/**
 * @return array<int, array{domain:?string, method:string, uri:string, name:?string, action:string, middleware:array<int,string>}>
 */
function fetchRoutes(): array
{
    $json = run('php artisan route:list --json');
    $decoded = json_decode($json, true);
    if (! is_array($decoded)) {
        throw new RuntimeException('Unable to parse route:list JSON.');
    }

    return $decoded;
}

function categoryForUri(string $uri): string
{
    if (str_starts_with($uri, '/api/admin/')) {
        return 'Admin (Super)';
    }
    if (str_starts_with($uri, '/api/legacy-admin/')) {
        return 'Admin (Legacy)';
    }
    if (str_starts_with($uri, '/api/auth/')) {
        return 'Auth';
    }
    if (str_starts_with($uri, '/api/feed/')) {
        return 'Feed';
    }
    if (str_starts_with($uri, '/api/webhooks/')) {
        return 'Webhooks';
    }
    if (str_starts_with($uri, '/api/seller/')) {
        return 'Seller';
    }
    if (str_starts_with($uri, '/api/rider/')) {
        return 'Rider';
    }

    if (in_array($uri, ['/api/zones', '/api/shops', '/api/products'], true)
        || str_starts_with($uri, '/api/shops/')
        || str_starts_with($uri, '/api/products/')) {
        return 'Public';
    }

    return 'User';
}

/**
 * @return array{raw:string, host:array<int,string>, path:array<int,string>}
 */
function postmanUrlFor(string $uri, array &$variables): array
{
    $raw = '{{base_url}}'.$uri;

    $pathParts = array_values(array_filter(explode('/', ltrim($uri, '/')), fn ($p) => $p !== ''));
    $path = [];
    foreach ($pathParts as $part) {
        if (preg_match('/^\{([a-zA-Z0-9_]+)\??\}$/', $part, $m) === 1) {
            $key = $m[1];
            $variables[$key] = $variables[$key] ?? '';
            $path[] = '{{'.$key.'}}';
            $raw = str_replace('{'.$key.'}', '{{'.$key.'}}', $raw);
            $raw = str_replace('{'.$key.'?}', '{{'.$key.'}}', $raw);
            continue;
        }

        $path[] = $part;
    }

    return [
        'raw' => $raw,
        'host' => ['{{base_url}}'],
        'path' => $path,
    ];
}

/**
 * @return array<int, array{key:string, value:string}>
 */
function headersFor(string $method, string $uri, array $middleware): array
{
    $headers = [];

    if (in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'], true)) {
        $headers[] = ['key' => 'Content-Type', 'value' => 'application/json'];
    }

    $isUserAuthed = in_array('auth:sanctum', $middleware, true)
        || in_array('Illuminate\\Auth\\Middleware\\Authenticate:sanctum', $middleware, true);

    $isAdminAuthed = in_array('auth:admin', $middleware, true)
        || in_array('Illuminate\\Auth\\Middleware\\Authenticate:admin', $middleware, true);

    if ($isUserAuthed) {
        $headers[] = ['key' => 'Authorization', 'value' => 'Bearer {{token}}'];
    }

    if ($isAdminAuthed) {
        $headers[] = ['key' => 'Authorization', 'value' => 'Bearer {{admin_token}}'];
    }

    return $headers;
}

/**
 * @return array{mode:string, raw:string}|null
 */
function bodyFor(string $method, string $uri, array $middleware): ?array
{
    if (! in_array($method, ['POST', 'PUT', 'PATCH', 'DELETE'], true)) {
        return null;
    }

    if (str_starts_with($uri, '/api/admin/') && ! str_starts_with($uri, '/api/admin/auth/login')) {
        return ['mode' => 'raw', 'raw' => "{\n  \"reason\": \"\"\n}\n"];
    }

    return ['mode' => 'raw', 'raw' => "{\n}\n"];
}

/**
 * @return array<int, string>
 */
function expandMethods(string $methodStr): array
{
    $parts = array_values(array_filter(explode('|', strtoupper($methodStr))));
    $parts = array_values(array_filter($parts, fn ($m) => $m !== 'HEAD'));

    return $parts;
}

$routes = fetchRoutes();

// Build folder containers.
$folders = [];
$variables = [
    'base_url' => 'http://127.0.0.1:8000',
    'token' => '',
    'admin_token' => '',
];

foreach ($routes as $r) {
    if (! is_array($r) || ! isset($r['uri'], $r['method'], $r['middleware'])) {
        continue;
    }

    $uri = (string) $r['uri'];
    if ($uri !== '' && $uri[0] !== '/') {
        $uri = '/'.$uri;
    }
    $methodStr = (string) $r['method'];
    $middleware = is_array($r['middleware']) ? $r['middleware'] : [];

    // Only include API routes (skip duplicates under /api/v1/*).
    if (! str_starts_with($uri, '/api/')) {
        continue;
    }
    if (str_starts_with($uri, '/api/v1/')) {
        continue;
    }

    foreach (expandMethods($methodStr) as $method) {
        $folder = categoryForUri($uri);
        $folders[$folder] ??= [];

        $urlObj = postmanUrlFor($uri, $variables);
        $req = [
            'method' => $method,
            'header' => headersFor($method, $uri, $middleware),
            'url' => $urlObj,
        ];

        $body = bodyFor($method, $uri, $middleware);
        if ($body) {
            $req['body'] = $body;
        }

        $folders[$folder][] = [
            'name' => "{$method} {$uri}",
            'request' => $req,
        ];
    }
}

ksort($folders);
$items = [];
foreach ($folders as $name => $requests) {
    $items[] = [
        'name' => $name,
        'item' => $requests,
    ];
}

$collection = [
    'info' => [
        'name' => 'Smartlink API',
        '_postman_id' => 'b7d2a6b1-5c3f-4f40-9e70-6d0c3d3e9c1a',
        'schema' => 'https://schema.getpostman.com/json/collection/v2.1.0/collection.json',
    ],
    'item' => $items,
    'variable' => array_values(array_map(
        fn ($k, $v) => ['key' => (string) $k, 'value' => (string) $v],
        array_keys($variables),
        array_values($variables),
    )),
];

@mkdir(__DIR__.'/../postman', 0777, true);
$outPath = __DIR__.'/../postman/Smartlink.postman_collection.json';
file_put_contents($outPath, json_encode($collection, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES)."\n");

echo "Wrote {$outPath}\n";
