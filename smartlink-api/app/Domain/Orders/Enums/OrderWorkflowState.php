<?php

namespace App\Domain\Orders\Enums;

enum OrderWorkflowState: string
{
    case None = 'none';
    case InProgress = 'in_progress';
    case Ready = 'ready';
    case Completed = 'completed';
    case Blocked = 'blocked';
}

