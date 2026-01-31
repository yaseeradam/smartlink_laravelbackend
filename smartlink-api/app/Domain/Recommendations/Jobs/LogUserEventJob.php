<?php

namespace App\Domain\Recommendations\Jobs;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;

class LogUserEventJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    /**
     * @param  array{user_id?:int|null, session_id?:string|null, zone_id:int, event_type:string, entity_type?:string|null, entity_id?:int|null, query_text?:string|null, meta_json?:array<string,mixed>|null}  $payload
     */
    public function __construct(public readonly array $payload)
    {
    }

    public function handle(): void
    {
        DB::table('user_events')->insert([
            'user_id' => $this->payload['user_id'] ?? null,
            'session_id' => $this->payload['session_id'] ?? null,
            'zone_id' => (int) $this->payload['zone_id'],
            'event_type' => (string) $this->payload['event_type'],
            'entity_type' => $this->payload['entity_type'] ?? null,
            'entity_id' => $this->payload['entity_id'] ?? null,
            'query_text' => $this->payload['query_text'] ?? null,
            'meta_json' => isset($this->payload['meta_json']) ? json_encode($this->payload['meta_json']) : null,
            'created_at' => now(),
        ]);
    }
}

