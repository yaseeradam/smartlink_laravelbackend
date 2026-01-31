<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->enum('fulfillment_mode', ['local_rider', 'shipping'])
                ->default('local_rider')
                ->after('zone_id');
            $table->index(['fulfillment_mode']);
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropIndex(['fulfillment_mode']);
            $table->dropColumn(['fulfillment_mode']);
        });
    }
};

