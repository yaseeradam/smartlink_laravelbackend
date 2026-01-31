<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shipments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->enum('shipping_type', ['seller_handled', 'partner'])->default('seller_handled');
            $table->string('courier_name')->nullable();
            $table->string('tracking_number')->nullable();
            $table->string('origin_state')->nullable();
            $table->string('destination_state')->nullable();
            $table->decimal('shipping_fee', 14, 2)->default(0);
            $table->enum('status', [
                'pending',
                'packed',
                'dropped_off',
                'in_transit',
                'out_for_delivery',
                'delivered',
                'confirmed',
                'failed',
            ])->default('pending');
            $table->string('proof_dropoff_url')->nullable();
            $table->string('proof_delivery_url')->nullable();
            $table->unsignedSmallInteger('eta_days_min')->nullable();
            $table->unsignedSmallInteger('eta_days_max')->nullable();
            $table->timestamps();

            $table->unique('order_id');
            $table->index(['status']);
        });

        Schema::create('shipment_status_history', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shipment_id')->constrained('shipments')->cascadeOnDelete();
            $table->string('status');
            $table->foreignId('changed_by_user_id')->nullable()->constrained('users');
            $table->json('meta_json')->nullable();
            $table->timestamps();

            $table->index(['shipment_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shipment_status_history');
        Schema::dropIfExists('shipments');
    }
};

