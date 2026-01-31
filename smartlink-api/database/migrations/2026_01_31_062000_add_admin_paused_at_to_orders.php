<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->timestamp('admin_paused_at')->nullable()->after('fulfillment_mode');
            $table->index(['admin_paused_at']);
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropIndex(['admin_paused_at']);
            $table->dropColumn(['admin_paused_at']);
        });
    }
};

