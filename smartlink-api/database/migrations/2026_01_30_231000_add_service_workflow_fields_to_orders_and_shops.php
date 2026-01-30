<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('shops', function (Blueprint $table) {
            $table->dropUnique(['seller_user_id']);

            $table->enum('shop_type', ['retail', 'food', 'repair', 'tailor', 'laundry', 'print'])
                ->default('retail')
                ->after('verification_phase');

            $table->foreignId('default_workflow_id')
                ->nullable()
                ->after('shop_type')
                ->constrained('workflows')
                ->nullOnDelete();

            $table->index(['seller_user_id', 'shop_type']);
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->enum('order_kind', ['product', 'service'])->default('product')->after('shop_id');
            $table->enum('service_type', ['retail', 'food', 'repair', 'tailor', 'laundry', 'print'])
                ->nullable()
                ->after('order_kind');

            $table->foreignId('workflow_id')
                ->nullable()
                ->after('service_type')
                ->constrained('workflows')
                ->nullOnDelete();

            $table->foreignId('workflow_step_id')
                ->nullable()
                ->after('workflow_id')
                ->constrained('workflow_steps')
                ->nullOnDelete();

            $table->enum('workflow_state', ['none', 'in_progress', 'ready', 'completed', 'blocked'])
                ->default('none')
                ->after('workflow_step_id');

            $table->unsignedInteger('workflow_eta_min')->nullable()->after('workflow_state');
            $table->unsignedInteger('workflow_eta_max')->nullable()->after('workflow_eta_min');
            $table->timestamp('workflow_started_at')->nullable()->after('workflow_eta_max');
            $table->timestamp('workflow_completed_at')->nullable()->after('workflow_started_at');

            $table->text('issue_description')->nullable()->after('workflow_completed_at');
            $table->decimal('quoted_amount', 14, 2)->nullable()->after('issue_description');
            $table->enum('quote_status', ['none', 'sent', 'approved', 'rejected'])
                ->default('none')
                ->after('quoted_amount');
            $table->timestamp('quote_sent_at')->nullable()->after('quote_status');
            $table->timestamp('quote_approved_at')->nullable()->after('quote_sent_at');

            $table->index(['workflow_id', 'workflow_step_id']);
            $table->index(['order_kind', 'service_type']);
            $table->index(['quote_status']);
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropIndex(['workflow_id', 'workflow_step_id']);
            $table->dropIndex(['order_kind', 'service_type']);
            $table->dropIndex(['quote_status']);

            $table->dropConstrainedForeignId('workflow_step_id');
            $table->dropConstrainedForeignId('workflow_id');

            $table->dropColumn([
                'order_kind',
                'service_type',
                'workflow_step_id',
                'workflow_id',
                'workflow_state',
                'workflow_eta_min',
                'workflow_eta_max',
                'workflow_started_at',
                'workflow_completed_at',
                'issue_description',
                'quoted_amount',
                'quote_status',
                'quote_sent_at',
                'quote_approved_at',
            ]);
        });

        Schema::table('shops', function (Blueprint $table) {
            $table->dropIndex(['seller_user_id', 'shop_type']);
            $table->dropConstrainedForeignId('default_workflow_id');
            $table->dropColumn(['shop_type']);
            $table->unique('seller_user_id');
        });
    }
};

