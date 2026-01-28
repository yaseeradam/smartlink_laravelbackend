<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('zones', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('city');
            $table->string('state');
            $table->json('polygon_geojson')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('user_zones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('zone_id')->constrained('zones');
            $table->enum('type', ['home', 'operational']);
            $table->timestamps();

            $table->unique(['user_id', 'type']);
        });

        Schema::create('shops', function (Blueprint $table) {
            $table->id();
            $table->foreignId('seller_user_id')->constrained('users');
            $table->string('shop_name');
            $table->text('description')->nullable();
            $table->foreignId('zone_id')->constrained('zones');
            $table->string('address_text');
            $table->boolean('is_verified')->default(false);
            $table->enum('verification_phase', ['phase1', 'phase2'])->default('phase1');
            $table->timestamps();

            $table->unique('seller_user_id');
            $table->index(['zone_id', 'is_verified']);
        });

        Schema::create('seller_bank_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('seller_user_id')->constrained('users');
            $table->string('bank_name');
            $table->string('account_number');
            $table->string('account_name');
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();

            $table->unique('seller_user_id');
        });

        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shop_id')->constrained('shops');
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('price', 14, 2);
            $table->string('currency', 3)->default('NGN');
            $table->integer('stock_qty')->default(0);
            $table->enum('status', ['active', 'inactive', 'out_of_stock'])->default('active');
            $table->timestamps();

            $table->index(['shop_id', 'status']);
        });

        Schema::create('product_images', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained('products')->cascadeOnDelete();
            $table->string('image_url');
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->index(['product_id', 'sort_order']);
        });

        Schema::create('rider_profiles', function (Blueprint $table) {
            $table->foreignId('rider_user_id')->primary()->constrained('users');
            $table->enum('vehicle_type', ['bike', 'car', 'tricycle']);
            $table->string('plate_number')->nullable();
            $table->boolean('is_elite')->default(false);
            $table->string('qr_code_token')->unique();
            $table->timestamps();
        });

        Schema::create('rider_availability', function (Blueprint $table) {
            $table->foreignId('rider_user_id')->primary()->constrained('users');
            $table->enum('status', ['offline', 'available', 'busy'])->default('offline');
            $table->timestamp('last_seen_at')->nullable();
        });

        Schema::create('seller_rider_pools', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shop_id')->constrained('shops')->cascadeOnDelete();
            $table->foreignId('rider_user_id')->constrained('users');
            $table->enum('status', ['invited', 'active', 'removed'])->default('invited');
            $table->foreignId('added_by')->constrained('users');
            $table->timestamps();

            $table->unique(['shop_id', 'rider_user_id']);
        });

        Schema::create('wallet_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->string('currency', 3)->default('NGN');
            $table->decimal('available_balance', 14, 2)->default(0);
            $table->enum('status', ['active', 'frozen'])->default('active');
            $table->timestamps();

            $table->unique('user_id');
        });

        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_account_id')->constrained('wallet_accounts');
            $table->enum('type', ['topup', 'debit', 'credit', 'hold', 'release', 'refund', 'fee']);
            $table->enum('direction', ['in', 'out']);
            $table->decimal('amount', 14, 2);
            $table->string('reference')->unique();
            $table->string('related_entity_type')->nullable();
            $table->unsignedBigInteger('related_entity_id')->nullable();
            $table->json('meta_json')->nullable();
            $table->timestamps();

            $table->index(['wallet_account_id', 'created_at']);
        });

        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('buyer_user_id')->constrained('users');
            $table->foreignId('shop_id')->constrained('shops');
            $table->foreignId('zone_id')->constrained('zones');
            $table->decimal('subtotal_amount', 14, 2);
            $table->decimal('delivery_fee_amount', 14, 2)->default(0);
            $table->decimal('total_amount', 14, 2);
            $table->enum('status', [
                'placed',
                'paid',
                'accepted_by_seller',
                'dispatching',
                'assigned_to_rider',
                'picked_up',
                'delivered',
                'confirmed',
                'cancelled',
                'disputed',
            ])->default('placed');
            $table->enum('payment_status', ['pending', 'paid', 'refunded'])->default('pending');
            $table->string('delivery_address_text');
            $table->timestamps();

            $table->index(['buyer_user_id', 'status']);
            $table->index(['shop_id', 'status']);
        });

        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('product_id')->constrained('products');
            $table->integer('qty');
            $table->decimal('unit_price', 14, 2);
            $table->decimal('line_total', 14, 2);
        });

        Schema::create('order_status_history', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->string('status');
            $table->foreignId('changed_by_user_id')->nullable()->constrained('users');
            $table->timestamps();

            $table->index(['order_id', 'created_at']);
        });

        Schema::create('escrow_holds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders');
            $table->foreignId('buyer_wallet_account_id')->constrained('wallet_accounts');
            $table->foreignId('seller_user_id')->constrained('users');
            $table->decimal('amount', 14, 2);
            $table->enum('status', ['held', 'released', 'frozen', 'refunded'])->default('held');
            $table->timestamp('hold_expires_at')->nullable();
            $table->timestamps();

            $table->unique('order_id');
            $table->index(['seller_user_id', 'status']);
        });

        Schema::create('payouts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('seller_user_id')->constrained('users');
            $table->foreignId('order_id')->constrained('orders');
            $table->decimal('amount', 14, 2);
            $table->enum('status', ['pending', 'processing', 'paid', 'failed'])->default('pending');
            $table->enum('provider', ['paystack', 'flutterwave'])->default('paystack');
            $table->string('provider_ref')->nullable();
            $table->timestamps();

            $table->unique('order_id');
        });

        Schema::create('dispatch_jobs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders');
            $table->foreignId('shop_id')->constrained('shops');
            $table->foreignId('zone_id')->constrained('zones');
            $table->enum('status', ['pending', 'broadcasting', 'assigned', 'expired', 'cancelled'])->default('pending');
            $table->foreignId('assigned_rider_user_id')->nullable()->constrained('users');
            $table->timestamp('private_pool_only_until')->nullable();
            $table->timestamp('fallback_broadcast_at')->nullable();
            $table->timestamps();

            $table->unique('order_id');
            $table->index(['zone_id', 'status']);
        });

        Schema::create('dispatch_offers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('dispatch_job_id')->constrained('dispatch_jobs')->cascadeOnDelete();
            $table->foreignId('rider_user_id')->constrained('users');
            $table->enum('offer_status', ['sent', 'seen', 'accepted', 'declined', 'expired'])->default('sent');
            $table->timestamp('offered_at');
            $table->timestamp('responded_at')->nullable();

            $table->unique(['dispatch_job_id', 'rider_user_id']);
            $table->index(['rider_user_id', 'offer_status']);
        });

        Schema::create('order_evidence', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->enum('type', ['pickup_video', 'delivery_photo']);
            $table->string('file_url');
            $table->foreignId('captured_by_user_id')->constrained('users');
            $table->timestamps();
        });

        Schema::create('disputes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders');
            $table->foreignId('raised_by_user_id')->constrained('users');
            $table->enum('reason', ['wrong_item', 'damaged_item', 'not_delivered', 'other']);
            $table->text('description')->nullable();
            $table->enum('status', ['open', 'under_review', 'resolved', 'rejected'])->default('open');
            $table->foreignId('resolved_by_admin_id')->nullable()->constrained('users');
            $table->enum('resolution', [
                'refund_buyer',
                'pay_seller',
                'partial_refund',
                'penalize_rider',
                'penalize_seller',
            ])->nullable();
            $table->timestamps();

            $table->unique('order_id');
        });

        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('rater_user_id')->constrained('users');
            $table->foreignId('ratee_user_id')->constrained('users');
            $table->enum('ratee_type', ['seller', 'rider']);
            $table->unsignedTinyInteger('stars');
            $table->text('comment')->nullable();
            $table->timestamps();

            $table->unique(['order_id', 'rater_user_id', 'ratee_type']);
        });

        Schema::create('kyc_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->enum('kyc_type', ['buyer_basic', 'seller', 'rider']);
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->timestamp('submitted_at');
            $table->foreignId('reviewed_by')->nullable()->constrained('users');
            $table->timestamp('reviewed_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'kyc_type', 'status']);
        });

        Schema::create('kyc_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kyc_request_id')->constrained('kyc_requests')->cascadeOnDelete();
            $table->string('doc_type');
            $table->string('file_url');
            $table->timestamps();
        });

        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('actor_user_id')->nullable()->constrained('users');
            $table->string('action');
            $table->string('auditable_type')->nullable();
            $table->unsignedBigInteger('auditable_id')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->json('meta_json')->nullable();
            $table->timestamps();

            $table->index(['action', 'created_at']);
            $table->index(['auditable_type', 'auditable_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('kyc_documents');
        Schema::dropIfExists('kyc_requests');
        Schema::dropIfExists('ratings');
        Schema::dropIfExists('disputes');
        Schema::dropIfExists('order_evidence');
        Schema::dropIfExists('dispatch_offers');
        Schema::dropIfExists('dispatch_jobs');
        Schema::dropIfExists('payouts');
        Schema::dropIfExists('escrow_holds');
        Schema::dropIfExists('order_status_history');
        Schema::dropIfExists('order_items');
        Schema::dropIfExists('orders');
        Schema::dropIfExists('wallet_transactions');
        Schema::dropIfExists('wallet_accounts');
        Schema::dropIfExists('seller_rider_pools');
        Schema::dropIfExists('rider_availability');
        Schema::dropIfExists('rider_profiles');
        Schema::dropIfExists('product_images');
        Schema::dropIfExists('products');
        Schema::dropIfExists('seller_bank_accounts');
        Schema::dropIfExists('shops');
        Schema::dropIfExists('user_zones');
        Schema::dropIfExists('zones');
    }
};

