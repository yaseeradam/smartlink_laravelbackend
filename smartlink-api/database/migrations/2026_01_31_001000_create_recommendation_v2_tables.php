<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('session_id')->nullable();
            $table->foreignId('zone_id')->constrained('zones');
            $table->enum('event_type', [
                'view_shop',
                'view_product',
                'search',
                'add_to_cart',
                'start_checkout',
                'place_order',
                'rate',
                'favorite_shop',
            ]);
            $table->enum('entity_type', ['shop', 'product', 'category'])->nullable();
            $table->unsignedBigInteger('entity_id')->nullable();
            $table->text('query_text')->nullable();
            $table->json('meta_json')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index(['zone_id', 'created_at']);
            $table->index(['user_id', 'created_at']);
            $table->index(['entity_type', 'entity_id', 'created_at']);
        });

        Schema::create('shop_metrics_daily', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shop_id')->constrained('shops')->cascadeOnDelete();
            $table->foreignId('zone_id')->constrained('zones');
            $table->date('date');
            $table->unsignedInteger('orders_count')->default(0);
            $table->unsignedInteger('completed_orders_count')->default(0);
            $table->unsignedInteger('cancelled_orders_count')->default(0);
            $table->unsignedInteger('disputes_count')->default(0);
            $table->decimal('avg_rating', 4, 3)->default(0);
            $table->unsignedInteger('ratings_count')->default(0);
            $table->unsignedInteger('avg_delivery_minutes')->nullable();
            $table->unsignedInteger('avg_prep_minutes')->nullable();
            $table->timestamps();

            $table->unique(['shop_id', 'date']);
            $table->index(['zone_id', 'date']);
        });

        Schema::create('shop_trust_metrics', function (Blueprint $table) {
            $table->foreignId('shop_id')->primary()->constrained('shops')->cascadeOnDelete();
            $table->decimal('trust_score', 5, 2)->default(0);
            $table->decimal('dispute_rate', 8, 6)->default(0);
            $table->decimal('cancellation_rate', 8, 6)->default(0);
            $table->decimal('fulfillment_success_rate', 8, 6)->default(0);
            $table->enum('kyc_level', ['none', 'basic', 'verified'])->default('none');
            $table->decimal('rating_bayesian', 4, 3)->default(0);
            $table->timestamp('last_calculated_at')->nullable();
            $table->timestamps();
        });

        Schema::create('shop_tags', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shop_id')->constrained('shops')->cascadeOnDelete();
            $table->string('tag', 50);
            $table->enum('tag_type', ['cuisine', 'service', 'keyword']);
            $table->timestamps();

            $table->unique(['shop_id', 'tag']);
            $table->index(['tag', 'tag_type']);
        });

        Schema::create('user_preferences', function (Blueprint $table) {
            $table->foreignId('user_id')->primary()->constrained('users')->cascadeOnDelete();
            $table->json('preferred_tags_json')->nullable();
            $table->enum('preferred_price_band', ['low', 'mid', 'high'])->nullable();
            $table->timestamp('last_updated_at')->nullable();
        });

        Schema::create('user_favorites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('shop_id')->constrained('shops')->cascadeOnDelete();
            $table->timestamp('created_at')->useCurrent();

            $table->unique(['user_id', 'shop_id']);
            $table->index(['shop_id', 'created_at']);
        });

        Schema::create('shop_cooccurrence', function (Blueprint $table) {
            $table->id();
            $table->foreignId('zone_id')->constrained('zones')->cascadeOnDelete();
            $table->foreignId('shop_a_id')->constrained('shops')->cascadeOnDelete();
            $table->foreignId('shop_b_id')->constrained('shops')->cascadeOnDelete();
            $table->decimal('weight', 14, 6)->default(0);
            $table->timestamp('updated_at')->useCurrent();

            $table->unique(['zone_id', 'shop_a_id', 'shop_b_id']);
            $table->index(['zone_id', 'weight']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shop_cooccurrence');
        Schema::dropIfExists('user_favorites');
        Schema::dropIfExists('user_preferences');
        Schema::dropIfExists('shop_tags');
        Schema::dropIfExists('shop_trust_metrics');
        Schema::dropIfExists('shop_metrics_daily');
        Schema::dropIfExists('user_events');
    }
};

