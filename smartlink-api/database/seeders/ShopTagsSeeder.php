<?php

namespace Database\Seeders;

use BackedEnum;
use App\Domain\Recommendations\Models\ShopTag;
use App\Domain\Shops\Models\Shop;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ShopTagsSeeder extends Seeder
{
    public function run(): void
    {
        DB::transaction(function () {
            $shops = Shop::query()->get(['id', 'shop_type']);

            foreach ($shops as $shop) {
                $type = $shop->shop_type instanceof BackedEnum ? (string) $shop->shop_type->value : (string) $shop->shop_type;
                $tags = $this->tagsForType($type);

                foreach ($tags as $tag) {
                    ShopTag::query()->firstOrCreate(
                        ['shop_id' => $shop->id, 'tag' => $tag['tag']],
                        ['tag_type' => $tag['tag_type']],
                    );
                }
            }
        });
    }

    /**
     * @return list<array{tag:string, tag_type:'cuisine'|'service'|'keyword'}>
     */
    private function tagsForType(string $shopType): array
    {
        return match ($shopType) {
            'food' => [
                ['tag' => 'rice', 'tag_type' => 'cuisine'],
                ['tag' => 'grill', 'tag_type' => 'cuisine'],
                ['tag' => 'snacks', 'tag_type' => 'cuisine'],
                ['tag' => 'fast_food', 'tag_type' => 'keyword'],
                ['tag' => 'delivery', 'tag_type' => 'service'],
            ],
            'repair' => [
                ['tag' => 'repair', 'tag_type' => 'service'],
                ['tag' => 'phone_repair', 'tag_type' => 'keyword'],
                ['tag' => 'computer_repair', 'tag_type' => 'keyword'],
            ],
            'tailor' => [
                ['tag' => 'tailoring', 'tag_type' => 'service'],
                ['tag' => 'fashion', 'tag_type' => 'keyword'],
                ['tag' => 'alterations', 'tag_type' => 'keyword'],
            ],
            'laundry' => [
                ['tag' => 'laundry', 'tag_type' => 'service'],
                ['tag' => 'ironing', 'tag_type' => 'service'],
                ['tag' => 'fast', 'tag_type' => 'keyword'],
            ],
            'print' => [
                ['tag' => 'printing', 'tag_type' => 'service'],
                ['tag' => 'design', 'tag_type' => 'service'],
                ['tag' => 'business_cards', 'tag_type' => 'keyword'],
            ],
            default => [
                ['tag' => 'retail', 'tag_type' => 'keyword'],
                ['tag' => 'delivery', 'tag_type' => 'service'],
            ],
        };
    }
}
