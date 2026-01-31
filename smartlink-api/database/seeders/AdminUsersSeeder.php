<?php

namespace Database\Seeders;

use App\Domain\Admin\Models\AdminUser;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminUsersSeeder extends Seeder
{
    public function run(): void
    {
        $email = (string) env('ADMIN_EMAIL', '');
        $password = (string) env('ADMIN_PASSWORD', '');

        if (trim($email) === '' || trim($password) === '') {
            return;
        }

        AdminUser::updateOrCreate(
            ['email' => $email],
            [
                'name' => 'Super Admin',
                'password_hash' => Hash::make($password),
                'is_active' => true,
            ],
        );
    }
}

