<?php

return [
    'country_code' => env('SMARTLINK_COUNTRY_CODE', 'NG'),
    'currency' => env('SMARTLINK_CURRENCY', 'NGN'),
    'media_disk' => env('SMARTLINK_MEDIA_DISK', env('FILESYSTEM_DISK', 'local')),

    'escrow' => [
        'auto_release_hours' => (int) env('SMARTLINK_ESCROW_AUTO_RELEASE_HOURS', 24),
    ],

    'shipping' => [
        'auto_release_hours' => (int) env('SMARTLINK_SHIPPING_AUTO_RELEASE_HOURS', 72),
    ],

    'dispatch' => [
        'private_pool_minutes' => (int) env('SMARTLINK_DISPATCH_PRIVATE_POOL_MINUTES', 10),
    ],

    'delivery_fees' => [
        'default_base_fee' => (float) env('SMARTLINK_DELIVERY_BASE_FEE', 0),
        'default_rider_share_percent' => (float) env('SMARTLINK_DELIVERY_RIDER_SHARE_PERCENT', 70),
        'default_platform_fee_percent' => (float) env('SMARTLINK_DELIVERY_PLATFORM_FEE_PERCENT', 30),
    ],

    'delivery' => [
        'otp_required' => (bool) env('SMARTLINK_DELIVERY_OTP_REQUIRED', false),
        'otp_ttl_minutes' => (int) env('SMARTLINK_DELIVERY_OTP_TTL_MINUTES', 30),
    ],

    'returns' => [
        'window_hours' => (int) env('SMARTLINK_RETURN_WINDOW_HOURS', 48),
        'fallback_minutes' => (int) env('SMARTLINK_RETURN_FALLBACK_MINUTES', 10),
    ],

    'cancellations' => [
        'seller_penalty_amount' => (float) env('SMARTLINK_SELLER_CANCELLATION_PENALTY', 0),
        'rider_penalty_amount' => (float) env('SMARTLINK_RIDER_CANCELLATION_PENALTY', 0),
    ],

    'fraud' => [
        'new_account_max_order_amount' => (float) env('SMARTLINK_NEW_ACCOUNT_MAX_ORDER', 10000),
        'new_account_age_days' => (int) env('SMARTLINK_NEW_ACCOUNT_AGE_DAYS', 7),
        'dispute_abuse_threshold' => (int) env('SMARTLINK_DISPUTE_ABUSE_THRESHOLD', 3),
    ],

    'payouts' => [
        'minimum_threshold' => (float) env('SMARTLINK_PAYOUT_MINIMUM', 1000),
    ],

    'platform' => [
        'user_id' => env('SMARTLINK_PLATFORM_USER_ID'),
    ],

    'push' => [
        'driver' => env('PUSH_DRIVER', 'fcm'),
        'background_threshold_minutes' => (int) env('PUSH_BACKGROUND_THRESHOLD_MINUTES', 5),
        'fcm' => [
            'server_key' => env('FCM_SERVER_KEY'),
            'base_url' => env('FCM_BASE_URL', 'https://fcm.googleapis.com/fcm/send'),
        ],
    ],

    'paystack' => [
        'secret_key' => env('PAYSTACK_SECRET_KEY'),
        'webhook_secret' => env('PAYSTACK_SECRET_KEY'), // Paystack uses the secret key for signature verification
        'base_url' => env('PAYSTACK_BASE_URL', 'https://api.paystack.co'),
    ],

    'otp' => [
        'driver' => env('OTP_DRIVER', 'termii'), // termii | sendchamp | log
        'sender_id' => env('OTP_SENDER_ID', 'Smartlink'),

        'termii' => [
            'api_key' => env('TERMII_API_KEY'),
            'base_url' => env('TERMII_BASE_URL', 'https://api.ng.termii.com'),
        ],

        'sendchamp' => [
            'api_key' => env('SENDCHAMP_API_KEY'),
            'base_url' => env('SENDCHAMP_BASE_URL', 'https://api.sendchamp.com/api/v1'),
        ],
    ],
];
