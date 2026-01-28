<?php

namespace Database\Seeders;

use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Seeder;

class ZonesSeeder extends Seeder
{
    public function run(): void
    {
        $zones = [
            ['name' => 'Yaba', 'city' => 'Lagos', 'state' => 'Lagos'],
            ['name' => 'Surulere', 'city' => 'Lagos', 'state' => 'Lagos'],
            ['name' => 'Wuse', 'city' => 'Abuja', 'state' => 'FCT'],
            ['name' => 'Garki', 'city' => 'Abuja', 'state' => 'FCT'],
        ];

        foreach ($zones as $zone) {
            Zone::updateOrCreate(
                ['name' => $zone['name'], 'city' => $zone['city'], 'state' => $zone['state']],
                ['is_active' => true, 'status' => 'active'],
            );
        }
    }
}
