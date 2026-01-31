<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('shipping_rates', function (Blueprint $table) {
            $table->id();
            $table->string('origin_state');
            $table->string('destination_state');
            $table->decimal('fee', 14, 2);
            $table->unsignedSmallInteger('eta_days_min')->nullable();
            $table->unsignedSmallInteger('eta_days_max')->nullable();
            $table->timestamps();

            $table->unique(['origin_state', 'destination_state']);
            $table->index(['origin_state', 'destination_state']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('shipping_rates');
    }
};

