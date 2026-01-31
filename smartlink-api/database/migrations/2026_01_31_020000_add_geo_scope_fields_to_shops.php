<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('shops', function (Blueprint $table) {
            $table->string('country_code', 2)->default('NG')->after('zone_id');
            $table->string('state_code')->nullable()->after('country_code');
            $table->string('city')->nullable()->after('state_code');

            $table->enum('shipping_type', ['local_rider', 'state_shipping', 'nation_shipping'])
                ->default('local_rider')
                ->after('longitude');
            $table->boolean('is_deliverable_outside_state')
                ->default(false)
                ->after('shipping_type');

            $table->index(['country_code', 'state_code']);
            $table->index(['state_code', 'city']);
            $table->index(['shipping_type']);
        });
    }

    public function down(): void
    {
        Schema::table('shops', function (Blueprint $table) {
            $table->dropIndex(['country_code', 'state_code']);
            $table->dropIndex(['state_code', 'city']);
            $table->dropIndex(['shipping_type']);

            $table->dropColumn([
                'country_code',
                'state_code',
                'city',
                'shipping_type',
                'is_deliverable_outside_state',
            ]);
        });
    }
};

