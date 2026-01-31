<?php

namespace Tests\Feature;

use App\Domain\Recommendations\Models\ShopCooccurrence;
use App\Domain\Recommendations\Models\UserFavorite;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Cache;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class RecommendationV2Test extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        Cache::flush();
        config(['recommendations.debug' => true]);
    }

    public function test_cold_start_fallback_works_without_metrics(): void
    {
        $zone = $this->makeZone();

        $seller = $this->makeSeller();
        $shop1 = $this->makeShop($seller, $zone->id, 'retail', 6.5244, 3.3792); // Lagos-ish
        $shop2 = $this->makeShop($seller, $zone->id, 'retail', 6.5344, 3.3792);

        $resp = $this->getJson("/api/feed/near-you?zone_id={$zone->id}&lat=6.5244&lng=3.3792")->assertOk();
        $ids = collect($resp->json('data'))->pluck('entity_id')->all();

        // Closest should win in cold-start (trust missing => distance dominates).
        $this->assertSame([$shop1->id, $shop2->id], array_slice($ids, 0, 2));
    }

    public function test_local_scope_excludes_other_states(): void
    {
        $lagos = Zone::create([
            'name' => 'Lagos Zone',
            'city' => 'Ikeja',
            'state' => 'Lagos',
            'is_active' => true,
            'status' => 'active',
        ]);
        $abuja = Zone::create([
            'name' => 'Abuja Zone',
            'city' => 'Wuse',
            'state' => 'FCT',
            'is_active' => true,
            'status' => 'active',
        ]);

        $seller1 = $this->makeSeller('08020001001', 's1@test.local');
        $seller2 = $this->makeSeller('08020001002', 's2@test.local');

        $localShop = $this->makeShop($seller1, $lagos->id, 'retail', 6.5244, 3.3792);
        $otherStateShop = $this->makeShop($seller2, $abuja->id, 'retail', 9.0579, 7.4951);

        $resp = $this->getJson("/api/feed/for-you?zone_id={$lagos->id}&scope=local&per_page=20&lat=6.5244&lng=3.3792")->assertOk();
        $ids = collect($resp->json('data'))->pluck('entity_id')->all();

        $this->assertContains($localShop->id, $ids);
        $this->assertNotContains($otherStateShop->id, $ids);
    }

    public function test_auto_scope_expands_local_to_state_then_stops_before_national_when_enough(): void
    {
        $buyerZone = Zone::create([
            'name' => 'Buyer Zone',
            'city' => 'Ikeja',
            'state' => 'Lagos',
            'is_active' => true,
            'status' => 'active',
        ]);
        $otherCitySameState = Zone::create([
            'name' => 'Other City Zone',
            'city' => 'Epe',
            'state' => 'Lagos',
            'is_active' => true,
            'status' => 'active',
        ]);
        $otherState = Zone::create([
            'name' => 'Other State Zone',
            'city' => 'Wuse',
            'state' => 'FCT',
            'is_active' => true,
            'status' => 'active',
        ]);

        $sellerLocal = $this->makeSeller('08020002001', 'local@test.local');
        $sellerState = $this->makeSeller('08020002002', 'state@test.local');
        $sellerNational = $this->makeSeller('08020002003', 'national@test.local');

        // Local (within ~10km of Ikeja)
        $local1 = $this->makeShop($sellerLocal, $buyerZone->id, 'retail', 6.5244, 3.3792);
        $local2 = $this->makeShop($this->makeSeller('08020002004', 'local2@test.local'), $buyerZone->id, 'retail', 6.5344, 3.3792);

        // Same state, other city, far away (outside local radius)
        $state1 = $this->makeShop($sellerState, $otherCitySameState->id, 'retail', 6.9244, 3.9792);
        $state2 = $this->makeShop($this->makeSeller('08020002005', 'state2@test.local'), $otherCitySameState->id, 'retail', 6.9344, 3.9892);
        $state3 = $this->makeShop($this->makeSeller('08020002006', 'state3@test.local'), $otherCitySameState->id, 'retail', 6.9444, 3.9992);

        // Other state (should not appear because state tier already fills limit)
        $national = $this->makeShop($sellerNational, $otherState->id, 'retail', 9.0579, 7.4951);

        foreach ([$local1, $local2, $state1, $state2, $state3, $national] as $shop) {
            $this->seedTrust($shop->id, trust: 50, ratingBayes: 0.5);
            $this->seedRatings30d($shop->id, (int) $shop->zone_id, 4.5, 10);
            Shop::query()->whereKey($shop->id)->update(['created_at' => now()]);
        }

        $resp = $this->getJson("/api/feed/for-you?zone_id={$buyerZone->id}&scope=auto&per_page=5&lat=6.5244&lng=3.3792")->assertOk();
        $items = $resp->json('data');

        $this->assertCount(5, $items);

        $tiers = collect($items)->pluck('meta.geo_tier')->all();
        $this->assertSame(['city', 'city', 'state', 'state', 'state'], $tiers);

        $ids = collect($items)->pluck('entity_id')->all();
        $this->assertNotContains($national->id, $ids);
    }

    public function test_location_penalty_prefers_same_city_over_other_city_within_state(): void
    {
        $buyerZone = Zone::create([
            'name' => 'Buyer Zone',
            'city' => 'Ikeja',
            'state' => 'Lagos',
            'is_active' => true,
            'status' => 'active',
        ]);
        $otherCitySameState = Zone::create([
            'name' => 'Other City Zone',
            'city' => 'Epe',
            'state' => 'Lagos',
            'is_active' => true,
            'status' => 'active',
        ]);

        $seller1 = $this->makeSeller('08020003001', 'p1@test.local');
        $seller2 = $this->makeSeller('08020003002', 'p2@test.local');

        $sameCity = $this->makeShop($seller1, $buyerZone->id, 'retail', 6.5244, 3.3792);
        $otherCity = $this->makeShop($seller2, $otherCitySameState->id, 'retail', 6.5244, 3.3792);

        $this->seedTrust($sameCity->id, trust: 60, ratingBayes: 0.6);
        $this->seedTrust($otherCity->id, trust: 60, ratingBayes: 0.6);
        $this->seedRatings30d($sameCity->id, $buyerZone->id, 4.5, 10);
        $this->seedRatings30d($otherCity->id, $otherCitySameState->id, 4.5, 10);
        Shop::query()->whereKey($sameCity->id)->update(['created_at' => now()]);
        Shop::query()->whereKey($otherCity->id)->update(['created_at' => now()]);

        $resp = $this->getJson("/api/feed/for-you?zone_id={$buyerZone->id}&scope=state&per_page=10")->assertOk();
        $ids = collect($resp->json('data'))->pluck('entity_id')->all();

        $this->assertSame($sameCity->id, (int) $ids[0]);
    }

    public function test_trust_beats_distance_when_nearby_shop_is_risky(): void
    {
        $zone = $this->makeZone();
        $seller1 = $this->makeSeller('08020000001', 'seller1@test.local');
        $seller2 = $this->makeSeller('08020000002', 'seller2@test.local');

        $nearRisky = $this->makeShop($seller1, $zone->id, 'food', 6.5244, 3.3792);
        $farTrusted = $this->makeShop($seller2, $zone->id, 'food', 6.5744, 3.4292);

        $this->seedTrust($nearRisky->id, trust: 10, ratingBayes: 0.4);
        $this->seedTrust($farTrusted->id, trust: 95, ratingBayes: 0.9);
        $this->seedRatings30d($nearRisky->id, $zone->id, 5, 3);
        $this->seedRatings30d($farTrusted->id, $zone->id, 5, 3);

        $resp = $this->getJson("/api/feed/near-you?zone_id={$zone->id}&lat=6.5244&lng=3.3792")->assertOk();
        $ids = collect($resp->json('data'))->pluck('entity_id')->all();

        $this->assertSame($farTrusted->id, $ids[0]);
    }

    public function test_diversity_rule_prevents_one_seller_dominating_top_k(): void
    {
        $zone = $this->makeZone();
        $dominantSeller = $this->makeSeller('08020000003', 'dominant@test.local');
        $otherSeller = $this->makeSeller('08020000004', 'other@test.local');
        $otherSeller2 = $this->makeSeller('08020000005', 'other2@test.local');

        $shopsDominant = [];
        for ($i = 0; $i < 3; $i++) {
            $shopsDominant[] = $this->makeShop($dominantSeller, $zone->id, 'retail', 6.5 + ($i * 0.01), 3.37);
        }
        $shopOther1 = $this->makeShop($otherSeller, $zone->id, 'retail', 6.55, 3.37);
        $shopOther2 = $this->makeShop($otherSeller2, $zone->id, 'retail', 6.56, 3.37);

        foreach ($shopsDominant as $s) {
            $this->seedTrust($s->id, trust: 99, ratingBayes: 0.9);
            $this->seedRatings30d($s->id, $zone->id, 5, 3);
        }
        $this->seedTrust($shopOther1->id, trust: 70, ratingBayes: 0.7);
        $this->seedTrust($shopOther2->id, trust: 65, ratingBayes: 0.7);
        $this->seedRatings30d($shopOther1->id, $zone->id, 5, 3);
        $this->seedRatings30d($shopOther2->id, $zone->id, 5, 3);

        $resp = $this->getJson("/api/feed/top-rated?zone_id={$zone->id}&per_page=10")->assertOk();
        $ids = collect($resp->json('data'))->pluck('entity_id')->all();

        $dominantCount = Shop::query()->whereIn('id', $ids)->where('seller_user_id', $dominantSeller->id)->count();
        $this->assertLessThanOrEqual(2, $dominantCount);
    }

    public function test_caching_returns_stable_results_within_ttl(): void
    {
        Cache::flush();

        $zone = $this->makeZone();
        $seller1 = $this->makeSeller('08020000006', 'cache1@test.local');
        $seller2 = $this->makeSeller('08020000007', 'cache2@test.local');

        $shopA = $this->makeShop($seller1, $zone->id, 'retail', 6.52, 3.37);
        $shopB = $this->makeShop($seller2, $zone->id, 'retail', 6.53, 3.37);

        $this->seedTrust($shopA->id, trust: 60, ratingBayes: 0.6);
        $this->seedTrust($shopB->id, trust: 50, ratingBayes: 0.6);
        $this->seedRatings30d($shopA->id, $zone->id, 5, 3);
        $this->seedRatings30d($shopB->id, $zone->id, 5, 3);

        $first = $this->getJson("/api/feed/top-rated?zone_id={$zone->id}&per_page=10")->assertOk()->json('data');
        $firstIds = collect($first)->pluck('entity_id')->all();

        // Swap trust scores, but cached response should remain stable.
        \DB::table('shop_trust_metrics')->where('shop_id', $shopA->id)->update(['trust_score' => 10]);
        \DB::table('shop_trust_metrics')->where('shop_id', $shopB->id)->update(['trust_score' => 90]);

        $second = $this->getJson("/api/feed/top-rated?zone_id={$zone->id}&per_page=10")->assertOk()->json('data');
        $secondIds = collect($second)->pluck('entity_id')->all();

        $this->assertSame($firstIds, $secondIds);
    }

    public function test_cooccurrence_influences_you_might_like_only_when_data_exists(): void
    {
        Cache::flush();

        $zone = $this->makeZone();
        $buyer = User::create([
            'full_name' => 'Buyer',
            'phone' => '08011111111',
            'email' => 'buyer@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);
        UserZone::create(['user_id' => $buyer->id, 'zone_id' => $zone->id, 'type' => 'home']);

        $seller = $this->makeSeller('08020000008', 'co@test.local');
        $seedShop = $this->makeShop($seller, $zone->id, 'retail', 6.52, 3.37);
        $suggestedShop = $this->makeShop($seller, $zone->id, 'retail', 6.53, 3.37);

        $this->seedTrust($seedShop->id, trust: 80, ratingBayes: 0.8);
        $this->seedTrust($suggestedShop->id, trust: 5, ratingBayes: 0.2);
        $this->seedRatings30d($seedShop->id, $zone->id, 5, 3);
        $this->seedRatings30d($suggestedShop->id, $zone->id, 5, 3);

        // Add other strong candidates so suggestedShop won't appear unless injected.
        for ($i = 0; $i < 12; $i++) {
            $s = $this->makeShop($this->makeSeller('08021'.str_pad((string) $i, 6, '0', STR_PAD_LEFT), "c{$i}@test.local"), $zone->id, 'retail', 6.54 + ($i * 0.001), 3.37);
            $this->seedTrust($s->id, trust: 90, ratingBayes: 0.9);
            $this->seedRatings30d($s->id, $zone->id, 5, 3);
        }

        UserFavorite::create(['user_id' => $buyer->id, 'shop_id' => $seedShop->id]);

        Sanctum::actingAs($buyer);

        $noCo = $this->getJson("/api/feed/for-you?zone_id={$zone->id}&per_page=10")->assertOk()->json('data');
        $this->assertEmpty(collect($noCo)->where('rank_reason', 'cooccurrence')->all());

        Cache::flush();

        ShopCooccurrence::query()->create([
            'zone_id' => $zone->id,
            'shop_a_id' => $seedShop->id,
            'shop_b_id' => $suggestedShop->id,
            'weight' => 100,
            'updated_at' => now(),
        ]);

        $withCo = $this->getJson("/api/feed/for-you?zone_id={$zone->id}&per_page=10")->assertOk()->json('data');
        $coItems = collect($withCo)->where('rank_reason', 'cooccurrence')->values()->all();

        $this->assertNotEmpty($coItems);
        $this->assertSame($suggestedShop->id, (int) $coItems[0]['entity_id']);
        $this->assertCount(1, $coItems); // subset only
    }

    private function makeZone(): Zone
    {
        return Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
            'status' => 'active',
        ]);
    }

    private function makeSeller(string $phone = '08022222222', string $email = 'seller@test.local'): User
    {
        return User::create([
            'full_name' => 'Seller',
            'phone' => $phone,
            'email' => $email,
            'password' => 'password',
            'role' => UserRole::Seller,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);
    }

    private function makeShop(User $seller, int $zoneId, string $type, float $lat, float $lng): Shop
    {
        return Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Shop '.uniqid(),
            'description' => null,
            'zone_id' => $zoneId,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
            'shop_type' => $type,
            'default_workflow_id' => null,
            'status' => 'active',
            'is_open' => true,
            'latitude' => $lat,
            'longitude' => $lng,
        ]);
    }

    private function seedTrust(int $shopId, float $trust, float $ratingBayes): void
    {
        \DB::table('shop_trust_metrics')->updateOrInsert(
            ['shop_id' => $shopId],
            [
                'trust_score' => $trust,
                'dispute_rate' => 0,
                'cancellation_rate' => 0,
                'fulfillment_success_rate' => 1,
                'kyc_level' => 'verified',
                'rating_bayesian' => $ratingBayes,
                'last_calculated_at' => now(),
                'updated_at' => now(),
                'created_at' => now(),
            ],
        );
    }

    private function seedRatings30d(int $shopId, int $zoneId, float $avgRating, int $ratingsCount): void
    {
        \DB::table('shop_metrics_daily')->updateOrInsert(
            ['shop_id' => $shopId, 'date' => now()->toDateString()],
            [
                'zone_id' => $zoneId,
                'orders_count' => 0,
                'completed_orders_count' => 0,
                'cancelled_orders_count' => 0,
                'disputes_count' => 0,
                'avg_rating' => $avgRating,
                'ratings_count' => $ratingsCount,
                'avg_delivery_minutes' => null,
                'avg_prep_minutes' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        );
    }
}
