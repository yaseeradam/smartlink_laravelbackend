<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('workflows', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('name');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('workflow_steps', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workflow_id')->constrained('workflows')->cascadeOnDelete();
            $table->string('step_key');
            $table->string('title');
            $table->unsignedInteger('sequence');
            $table->boolean('is_dispatch_trigger')->default(false);
            $table->boolean('is_terminal')->default(false);
            $table->timestamps();

            $table->unique(['workflow_id', 'step_key']);
            $table->index(['workflow_id', 'sequence']);
            $table->index(['workflow_id', 'is_dispatch_trigger']);
        });

        Schema::create('workflow_step_transitions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('workflow_id')->constrained('workflows')->cascadeOnDelete();
            $table->foreignId('from_step_id')->constrained('workflow_steps')->cascadeOnDelete();
            $table->foreignId('to_step_id')->constrained('workflow_steps')->cascadeOnDelete();

            $table->unique(['workflow_id', 'from_step_id', 'to_step_id'], 'workflow_step_transitions_unique');
            $table->index(['workflow_id', 'from_step_id']);
        });

        Schema::create('order_workflow_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('from_step_id')->nullable()->constrained('workflow_steps')->nullOnDelete();
            $table->foreignId('to_step_id')->constrained('workflow_steps')->cascadeOnDelete();
            $table->foreignId('changed_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['order_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('order_workflow_events');
        Schema::dropIfExists('workflow_step_transitions');
        Schema::dropIfExists('workflow_steps');
        Schema::dropIfExists('workflows');
    }
};
