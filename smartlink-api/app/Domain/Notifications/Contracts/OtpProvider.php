<?php

namespace App\Domain\Notifications\Contracts;

interface OtpProvider
{
    public function send(string $phone, string $message): void;
}

