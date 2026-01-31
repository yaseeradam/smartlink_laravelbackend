<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('shops', function (Blueprint $table) {
            $table->enum('status', ['active', 'inactive'])->default('active')->after('default_workflow_id');
            $table->boolean('is_open')->default(true)->after('status');
            $table->json('operating_hours_json')->nullable()->after('is_open');
            $table->decimal('latitude', 10, 7)->nullable()->after('operating_hours_json');
            $table->decimal('longitude', 10, 7)->nullable()->after('latitude');

            $table->index(['zone_id', 'status', 'is_verified']);
            $table->index(['zone_id', 'latitude', 'longitude']);
        });
    }

    public function down(): void
    {
        Schema::table('shops', function (Blueprint $table) {
            $table->dropIndex(['zone_id', 'status', 'is_verified']);
            $table->dropIndex(['zone_id', 'latitude', 'longitude']);
            $table->dropColumn(['status', 'is_open', 'operating_hours_json', 'latitude', 'longitude']);
        });
    }
};

