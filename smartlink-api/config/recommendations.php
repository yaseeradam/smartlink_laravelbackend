<?php

return [
    'debug' => (bool) env('RECOMMENDATIONS_DEBUG', false),
    'distance_d0_km' => (float) env('RECOMMENDATIONS_DISTANCE_D0_KM', 2.0),
    'near_you_radius_km' => (float) env('RECOMMENDATIONS_NEAR_YOU_RADIUS_KM', 10.0),
    'geo_penalties' => [
        'same_city' => (float) env('RECOMMENDATIONS_PENALTY_SAME_CITY', 0.0),
        'same_state' => (float) env('RECOMMENDATIONS_PENALTY_SAME_STATE', -0.05),
        'other_state' => (float) env('RECOMMENDATIONS_PENALTY_OTHER_STATE', -0.12),
    ],
    'cache_ttl_seconds' => [
        'home' => (int) env('RECOMMENDATIONS_CACHE_HOME_TTL', 300),
        'near_you' => (int) env('RECOMMENDATIONS_CACHE_NEAR_YOU_TTL', 300),
        'trending' => (int) env('RECOMMENDATIONS_CACHE_TRENDING_TTL', 300),
        'top_rated' => (int) env('RECOMMENDATIONS_CACHE_TOP_RATED_TTL', 300),
        'for_you' => (int) env('RECOMMENDATIONS_CACHE_FOR_YOU_TTL', 60),
        'ready_soon' => (int) env('RECOMMENDATIONS_CACHE_READY_SOON_TTL', 300),
    ],
    'diversity' => [
        'max_per_seller_in_top_k' => (int) env('RECOMMENDATIONS_MAX_PER_SELLER_TOP_K', 2),
        'top_k' => (int) env('RECOMMENDATIONS_DIVERSITY_TOP_K', 10),
        'max_consecutive_same_shop_type' => (int) env('RECOMMENDATIONS_MAX_CONSECUTIVE_SHOP_TYPE', 2),
    ],
    'bayesian' => [
        'm' => (int) env('RECOMMENDATIONS_BAYES_M', 5),
    ],
];
