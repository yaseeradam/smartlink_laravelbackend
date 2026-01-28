<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('zones', function (Blueprint $table) {
            $table->enum('status', ['active', 'paused'])->default('active')->after('is_active');
            $table->index('status');
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->decimal('rider_share_amount', 14, 2)->default(0)->after('delivery_fee_amount');
            $table->decimal('platform_fee_amount', 14, 2)->default(0)->after('rider_share_amount');
            $table->boolean('delivery_otp_required')->default(false)->after('delivery_address_text');
            $table->string('delivery_otp_hash')->nullable()->after('delivery_otp_required');
            $table->timestamp('delivery_otp_expires_at')->nullable()->after('delivery_otp_hash');
            $table->timestamp('delivery_otp_verified_at')->nullable()->after('delivery_otp_expires_at');
        });

        Schema::table('dispatch_jobs', function (Blueprint $table) {
            $table->enum('purpose', ['delivery', 'return'])->default('delivery')->after('zone_id');
            $table->dropUnique('dispatch_jobs_order_id_unique');
            $table->unique(['order_id', 'purpose']);
            $table->index(['purpose', 'status']);
        });

        Schema::create('user_devices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('device_token')->unique();
            $table->enum('platform', ['android', 'ios']);
            $table->timestamp('last_seen_at')->nullable();
            $table->timestamps();
        });

        Schema::create('delivery_pricing_rules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('zone_id')->constrained('zones')->cascadeOnDelete();
            $table->decimal('base_fee', 14, 2);
            $table->decimal('max_distance_km', 8, 2)->nullable();
            $table->decimal('rider_share_percent', 5, 2);
            $table->decimal('platform_fee_percent', 5, 2);
            $table->timestamps();

            $table->index(['zone_id', 'max_distance_km']);
        });

        Schema::create('cancellations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('cancelled_by_user_id')->constrained('users');
            $table->string('reason');
            $table->decimal('penalty_amount', 14, 2)->default(0);
            $table->timestamps();

            $table->unique('order_id');
        });

        Schema::create('returns', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->enum('status', ['requested', 'approved', 'rejected', 'completed'])->default('requested');
            $table->string('reason');
            $table->timestamps();

            $table->unique('order_id');
        });

        Schema::create('rider_stats', function (Blueprint $table) {
            $table->foreignId('rider_user_id')->primary()->constrained('users')->cascadeOnDelete();
            $table->decimal('acceptance_rate', 5, 2)->default(0);
            $table->decimal('cancellation_rate', 5, 2)->default(0);
            $table->decimal('avg_delivery_time', 8, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('sender_user_id')->constrained('users')->cascadeOnDelete();
            $table->text('message_text');
            $table->timestamps();

            $table->index(['order_id', 'created_at']);
        });

        Schema::create('blocked_entities', function (Blueprint $table) {
            $table->id();
            $table->enum('type', ['phone', 'device']);
            $table->string('value');
            $table->string('reason')->nullable();
            $table->timestamps();

            $table->unique(['type', 'value']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('blocked_entities');
        Schema::dropIfExists('messages');
        Schema::dropIfExists('rider_stats');
        Schema::dropIfExists('returns');
        Schema::dropIfExists('cancellations');
        Schema::dropIfExists('delivery_pricing_rules');
        Schema::dropIfExists('user_devices');

        Schema::table('dispatch_jobs', function (Blueprint $table) {
            $table->dropIndex(['purpose', 'status']);
            $table->dropUnique(['order_id', 'purpose']);
            $table->unique('order_id');
            $table->dropColumn('purpose');
        });

        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn([
                'rider_share_amount',
                'platform_fee_amount',
                'delivery_otp_required',
                'delivery_otp_hash',
                'delivery_otp_expires_at',
                'delivery_otp_verified_at',
            ]);
        });

        Schema::table('zones', function (Blueprint $table) {
            $table->dropIndex(['status']);
            $table->dropColumn('status');
        });
    }
};
