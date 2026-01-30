<?php

namespace App\Domain\Workflows\Services;

use App\Domain\Workflows\Models\Workflow;
use App\Domain\Workflows\Models\WorkflowStep;
use App\Domain\Workflows\Models\WorkflowStepTransition;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class WorkflowTemplateService
{
    /**
     * @param  array{code:string, name:string, is_active?:bool}  $payload
     */
    public function create(array $payload): Workflow
    {
        return DB::transaction(function () use ($payload): Workflow {
            try {
                return Workflow::create([
                    'code' => $payload['code'],
                    'name' => $payload['name'],
                    'is_active' => (bool) ($payload['is_active'] ?? true),
                ]);
            } catch (QueryException $e) {
                throw new \RuntimeException('Could not create workflow.');
            }
        });
    }

    /**
     * @param  array{name?:string, is_active?:bool}  $payload
     */
    public function update(Workflow $workflow, array $payload): Workflow
    {
        return DB::transaction(function () use ($workflow, $payload): Workflow {
            /** @var Workflow $locked */
            $locked = Workflow::query()->whereKey($workflow->id)->lockForUpdate()->firstOrFail();

            $locked->forceFill([
                'name' => $payload['name'] ?? $locked->name,
                'is_active' => array_key_exists('is_active', $payload) ? (bool) $payload['is_active'] : (bool) $locked->is_active,
            ])->save();

            return $locked->fresh(['steps', 'transitions']);
        });
    }

    /**
     * @param  array{step_key:string, title:string, sequence:int, is_dispatch_trigger?:bool, is_terminal?:bool}  $payload
     */
    public function addStep(Workflow $workflow, array $payload): WorkflowStep
    {
        return DB::transaction(function () use ($workflow, $payload): WorkflowStep {
            $this->assertDispatchTriggerUniqueness(
                (int) $workflow->id,
                $payload['is_dispatch_trigger'] ?? false,
                excludeStepId: null,
            );

            try {
                return WorkflowStep::create([
                    'workflow_id' => $workflow->id,
                    'step_key' => $payload['step_key'],
                    'title' => $payload['title'],
                    'sequence' => (int) $payload['sequence'],
                    'is_dispatch_trigger' => (bool) ($payload['is_dispatch_trigger'] ?? false),
                    'is_terminal' => (bool) ($payload['is_terminal'] ?? false),
                ]);
            } catch (QueryException $e) {
                throw new \RuntimeException('Could not create step (duplicate step_key?).');
            }
        });
    }

    /**
     * @param  array{step_key?:string, title?:string, sequence?:int, is_dispatch_trigger?:bool, is_terminal?:bool}  $payload
     */
    public function updateStep(WorkflowStep $step, array $payload): WorkflowStep
    {
        return DB::transaction(function () use ($step, $payload): WorkflowStep {
            /** @var WorkflowStep $locked */
            $locked = WorkflowStep::query()->whereKey($step->id)->lockForUpdate()->firstOrFail();

            $isDispatchTrigger = array_key_exists('is_dispatch_trigger', $payload)
                ? (bool) $payload['is_dispatch_trigger']
                : (bool) $locked->is_dispatch_trigger;

            $this->assertDispatchTriggerUniqueness(
                (int) $locked->workflow_id,
                $isDispatchTrigger,
                excludeStepId: (int) $locked->id,
            );

            $locked->forceFill([
                'step_key' => $payload['step_key'] ?? $locked->step_key,
                'title' => $payload['title'] ?? $locked->title,
                'sequence' => array_key_exists('sequence', $payload) ? (int) $payload['sequence'] : (int) $locked->sequence,
                'is_dispatch_trigger' => $isDispatchTrigger,
                'is_terminal' => array_key_exists('is_terminal', $payload) ? (bool) $payload['is_terminal'] : (bool) $locked->is_terminal,
            ])->save();

            return $locked->fresh();
        });
    }

    public function deleteStep(WorkflowStep $step): void
    {
        DB::transaction(function () use ($step): void {
            /** @var WorkflowStep $locked */
            $locked = WorkflowStep::query()->whereKey($step->id)->lockForUpdate()->firstOrFail();
            $locked->delete();
        });
    }

    public function addTransition(Workflow $workflow, string $fromStepKey, string $toStepKey): WorkflowStepTransition
    {
        if ($fromStepKey === $toStepKey) {
            throw new \RuntimeException('Invalid transition.');
        }

        return DB::transaction(function () use ($workflow, $fromStepKey, $toStepKey): WorkflowStepTransition {
            $from = WorkflowStep::query()
                ->where('workflow_id', $workflow->id)
                ->where('step_key', $fromStepKey)
                ->firstOrFail();

            $to = WorkflowStep::query()
                ->where('workflow_id', $workflow->id)
                ->where('step_key', $toStepKey)
                ->firstOrFail();

            return WorkflowStepTransition::query()->firstOrCreate([
                'workflow_id' => $workflow->id,
                'from_step_id' => $from->id,
                'to_step_id' => $to->id,
            ]);
        });
    }

    public function deleteTransition(Workflow $workflow, string $fromStepKey, string $toStepKey): void
    {
        DB::transaction(function () use ($workflow, $fromStepKey, $toStepKey): void {
            $fromId = WorkflowStep::query()
                ->where('workflow_id', $workflow->id)
                ->where('step_key', $fromStepKey)
                ->value('id');

            $toId = WorkflowStep::query()
                ->where('workflow_id', $workflow->id)
                ->where('step_key', $toStepKey)
                ->value('id');

            if (! $fromId || ! $toId) {
                return;
            }

            WorkflowStepTransition::query()
                ->where('workflow_id', $workflow->id)
                ->where('from_step_id', $fromId)
                ->where('to_step_id', $toId)
                ->delete();
        });
    }

    private function assertDispatchTriggerUniqueness(int $workflowId, bool $isDispatchTrigger, ?int $excludeStepId): void
    {
        if (! $isDispatchTrigger) {
            return;
        }

        $q = WorkflowStep::query()
            ->where('workflow_id', $workflowId)
            ->where('is_dispatch_trigger', true);

        if ($excludeStepId) {
            $q->where('id', '!=', $excludeStepId);
        }

        if ($q->exists()) {
            throw new \RuntimeException('Only one dispatch trigger step is allowed per workflow.');
        }
    }
}

