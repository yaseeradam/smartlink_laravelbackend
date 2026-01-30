<?php

namespace App\Domain\Shops\Services;

use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use App\Domain\Workflows\Models\Workflow;
use App\Domain\Workflows\Models\WorkflowStep;
use Illuminate\Support\Facades\DB;

class ShopWorkflowService
{
    public function setDefaultWorkflow(User $seller, Shop $shop, Workflow $workflow): Shop
    {
        return DB::transaction(function () use ($seller, $shop, $workflow): Shop {
            /** @var Shop $locked */
            $locked = Shop::query()->whereKey($shop->id)->lockForUpdate()->firstOrFail();

            if ((int) $locked->seller_user_id !== (int) $seller->id) {
                throw new \RuntimeException('Forbidden.');
            }

            if (! $workflow->is_active) {
                throw new \RuntimeException('Workflow is not active.');
            }

            $hasDispatchTrigger = WorkflowStep::query()
                ->where('workflow_id', $workflow->id)
                ->where('is_dispatch_trigger', true)
                ->exists();

            $hasTerminal = WorkflowStep::query()
                ->where('workflow_id', $workflow->id)
                ->where('is_terminal', true)
                ->exists();

            if (! $hasDispatchTrigger || ! $hasTerminal) {
                throw new \RuntimeException('Workflow must have a dispatch trigger step and a terminal step.');
            }

            $locked->forceFill(['default_workflow_id' => $workflow->id])->save();

            return $locked->fresh(['defaultWorkflow']);
        });
    }
}

