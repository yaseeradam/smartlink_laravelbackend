<?php

namespace Database\Seeders;

use App\Domain\Shops\Models\Shop;
use App\Domain\Workflows\Models\Workflow;
use App\Domain\Workflows\Models\WorkflowStep;
use App\Domain\Workflows\Models\WorkflowStepTransition;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class WorkflowsSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            foreach ($this->templates() as $template) {
                /** @var Workflow $workflow */
                $workflow = Workflow::query()->updateOrCreate(
                    ['code' => $template['code']],
                    ['name' => $template['name'], 'is_active' => true],
                );

                $stepsByKey = [];
                foreach ($template['steps'] as $step) {
                    /** @var WorkflowStep $saved */
                    $saved = WorkflowStep::query()->updateOrCreate(
                        ['workflow_id' => $workflow->id, 'step_key' => $step['step_key']],
                        [
                            'title' => $step['title'],
                            'sequence' => $step['sequence'],
                            'is_dispatch_trigger' => (bool) ($step['is_dispatch_trigger'] ?? false),
                            'is_terminal' => (bool) ($step['is_terminal'] ?? false),
                        ],
                    );

                    $stepsByKey[$saved->step_key] = $saved;
                }

                foreach ($template['transitions'] as $transition) {
                    $from = $stepsByKey[$transition[0]] ?? null;
                    $to = $stepsByKey[$transition[1]] ?? null;

                    if (! $from || ! $to) {
                        continue;
                    }

                    WorkflowStepTransition::query()->firstOrCreate([
                        'workflow_id' => $workflow->id,
                        'from_step_id' => $from->id,
                        'to_step_id' => $to->id,
                    ]);
                }
            }

            $workflowIdsByCode = Workflow::query()->pluck('id', 'code')->all();
            foreach (['food', 'repair', 'tailor', 'laundry', 'print'] as $code) {
                if (! isset($workflowIdsByCode[$code])) {
                    continue;
                }

                Shop::query()
                    ->whereNull('default_workflow_id')
                    ->where('shop_type', $code)
                    ->update(['default_workflow_id' => $workflowIdsByCode[$code]]);
            }

            Shop::query()
                ->whereNull('default_workflow_id')
                ->update(['default_workflow_id' => $workflowIdsByCode['retail'] ?? null]);
        });
    }

    /**
     * @return array<int, array{code:string, name:string, steps:array<int, array{step_key:string, title:string, sequence:int, is_dispatch_trigger?:bool, is_terminal?:bool}>, transitions:array<int, array{0:string, 1:string}>}>
     */
    private function templates(): array
    {
        return [
            [
                'code' => 'food',
                'name' => 'Food / Restaurant',
                'steps' => [
                    ['step_key' => 'accepted', 'title' => 'Accepted', 'sequence' => 1],
                    ['step_key' => 'cooking', 'title' => 'Cooking', 'sequence' => 2],
                    ['step_key' => 'baking', 'title' => 'Baking', 'sequence' => 2],
                    ['step_key' => 'ready_for_pickup', 'title' => 'Ready for Pickup', 'sequence' => 3, 'is_dispatch_trigger' => true],
                    ['step_key' => 'completed', 'title' => 'Completed', 'sequence' => 4, 'is_terminal' => true],
                ],
                'transitions' => [
                    ['accepted', 'cooking'],
                    ['accepted', 'baking'],
                    ['cooking', 'ready_for_pickup'],
                    ['baking', 'ready_for_pickup'],
                    ['ready_for_pickup', 'completed'],
                ],
            ],
            [
                'code' => 'repair',
                'name' => 'Repair (Service)',
                'steps' => [
                    ['step_key' => 'request_submitted', 'title' => 'Request Submitted', 'sequence' => 1],
                    ['step_key' => 'accepted', 'title' => 'Accepted', 'sequence' => 2],
                    ['step_key' => 'diagnosing', 'title' => 'Diagnosing', 'sequence' => 3],
                    ['step_key' => 'quote_sent', 'title' => 'Quote Sent', 'sequence' => 4],
                    ['step_key' => 'awaiting_approval', 'title' => 'Awaiting Customer Approval', 'sequence' => 5],
                    ['step_key' => 'repairing', 'title' => 'Repairing', 'sequence' => 6],
                    ['step_key' => 'testing', 'title' => 'Testing', 'sequence' => 7],
                    ['step_key' => 'ready', 'title' => 'Ready', 'sequence' => 8, 'is_dispatch_trigger' => true],
                    ['step_key' => 'completed', 'title' => 'Completed', 'sequence' => 9, 'is_terminal' => true],
                ],
                'transitions' => [
                    ['request_submitted', 'accepted'],
                    ['accepted', 'diagnosing'],
                    ['diagnosing', 'quote_sent'],
                    ['quote_sent', 'awaiting_approval'],
                    ['awaiting_approval', 'repairing'],
                    ['repairing', 'testing'],
                    ['testing', 'ready'],
                    ['ready', 'completed'],
                ],
            ],
            [
                'code' => 'tailor',
                'name' => 'Tailoring / Fashion',
                'steps' => [
                    ['step_key' => 'accepted', 'title' => 'Accepted', 'sequence' => 1],
                    ['step_key' => 'measurement', 'title' => 'Measurement', 'sequence' => 2],
                    ['step_key' => 'cutting', 'title' => 'Cutting', 'sequence' => 3],
                    ['step_key' => 'sewing', 'title' => 'Sewing', 'sequence' => 4],
                    ['step_key' => 'finishing', 'title' => 'Finishing', 'sequence' => 5],
                    ['step_key' => 'ready', 'title' => 'Ready', 'sequence' => 6, 'is_dispatch_trigger' => true],
                    ['step_key' => 'completed', 'title' => 'Completed', 'sequence' => 7, 'is_terminal' => true],
                ],
                'transitions' => [
                    ['accepted', 'measurement'],
                    ['measurement', 'cutting'],
                    ['cutting', 'sewing'],
                    ['sewing', 'finishing'],
                    ['finishing', 'ready'],
                    ['ready', 'completed'],
                ],
            ],
            [
                'code' => 'laundry',
                'name' => 'Laundry',
                'steps' => [
                    ['step_key' => 'accepted', 'title' => 'Accepted', 'sequence' => 1],
                    ['step_key' => 'washing', 'title' => 'Washing', 'sequence' => 2],
                    ['step_key' => 'drying', 'title' => 'Drying', 'sequence' => 3],
                    ['step_key' => 'ironing_folding', 'title' => 'Folding/Ironing', 'sequence' => 4],
                    ['step_key' => 'ready', 'title' => 'Ready', 'sequence' => 5, 'is_dispatch_trigger' => true],
                    ['step_key' => 'completed', 'title' => 'Completed', 'sequence' => 6, 'is_terminal' => true],
                ],
                'transitions' => [
                    ['accepted', 'washing'],
                    ['washing', 'drying'],
                    ['drying', 'ironing_folding'],
                    ['ironing_folding', 'ready'],
                    ['ready', 'completed'],
                ],
            ],
            [
                'code' => 'print',
                'name' => 'Printing',
                'steps' => [
                    ['step_key' => 'accepted', 'title' => 'Accepted', 'sequence' => 1],
                    ['step_key' => 'designing', 'title' => 'Designing', 'sequence' => 2],
                    ['step_key' => 'printing', 'title' => 'Printing', 'sequence' => 3],
                    ['step_key' => 'packaging', 'title' => 'Packaging', 'sequence' => 4],
                    ['step_key' => 'ready', 'title' => 'Ready', 'sequence' => 5, 'is_dispatch_trigger' => true],
                    ['step_key' => 'completed', 'title' => 'Completed', 'sequence' => 6, 'is_terminal' => true],
                ],
                'transitions' => [
                    ['accepted', 'designing'],
                    ['designing', 'printing'],
                    ['printing', 'packaging'],
                    ['packaging', 'ready'],
                    ['ready', 'completed'],
                ],
            ],
            [
                'code' => 'retail',
                'name' => 'Retail',
                'steps' => [
                    ['step_key' => 'accepted', 'title' => 'Accepted', 'sequence' => 1],
                    ['step_key' => 'ready', 'title' => 'Ready', 'sequence' => 2, 'is_dispatch_trigger' => true],
                    ['step_key' => 'completed', 'title' => 'Completed', 'sequence' => 3, 'is_terminal' => true],
                ],
                'transitions' => [
                    ['accepted', 'ready'],
                    ['ready', 'completed'],
                ],
            ],
        ];
    }
}
