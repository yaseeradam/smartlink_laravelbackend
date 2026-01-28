<?php

namespace App\Domain\Notifications\Contracts;

interface PushProvider
{
    /**
     * @param  list<string>  $deviceTokens
     * @param  array<string, mixed>  $data
     */
    public function send(array $deviceTokens, string $title, string $body, array $data = []): void;
}
