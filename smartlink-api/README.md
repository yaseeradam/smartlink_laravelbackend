# Smartlink API (Laravel 11)

Production-grade REST API backend for Smartlink (trust-first, hyper-local marketplace).

## Requirements

- PHP 8.2+
- Composer
- MySQL 8 (production)
- Redis (queues + cache)
- S3-compatible object storage (uploads)

## Setup

```bash
composer install
cp .env.example .env
php artisan key:generate
```

### Database (MySQL)

Set in `.env`:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=smartlink
DB_USERNAME=root
DB_PASSWORD=
```

Run migrations:

```bash
php artisan migrate
```

### Redis (cache + queue)

```env
CACHE_STORE=redis
QUEUE_CONNECTION=redis
REDIS_CLIENT=predis
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
```

Start workers:

```bash
php artisan queue:work redis
```

### Object storage (S3-compatible)

```env
SMARTLINK_MEDIA_DISK=s3
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=smartlink
AWS_ENDPOINT=https://your-s3-endpoint
AWS_USE_PATH_STYLE_ENDPOINT=true
```

### Paystack

```env
PAYSTACK_SECRET_KEY=sk_test_xxx
PAYSTACK_BASE_URL=https://api.paystack.co
```

Webhook endpoint:
- `POST /api/webhooks/paystack` (verifies `x-paystack-signature` using `PAYSTACK_SECRET_KEY`)

### SMS OTP (Termii / Sendchamp)

```env
OTP_DRIVER=log
OTP_SENDER_ID=Smartlink

TERMII_API_KEY=
TERMII_BASE_URL=https://api.ng.termii.com

SENDCHAMP_API_KEY=
SENDCHAMP_BASE_URL=https://api.sendchamp.com/api/v1
```

Use `OTP_DRIVER=log` locally to log OTPs instead of sending SMS.

## Seeding demo data

```bash
php artisan db:seed
```

Creates sample zones and demo users:
- Admin: `admin@smartlink.test` / `password`
- Buyer: `buyer@smartlink.test` / `password`
- Seller: `seller@smartlink.test` / `password`
- Rider: `rider@smartlink.test` / `password`

## Running tests

```bash
php artisan test
```

## Notes

- Wallet credits only happen from Paystack webhook (client cannot directly credit wallets).
- Money actions are ledger-based (`wallet_transactions`) and audit-logged (`audit_logs`).
- Dispatch uses queued jobs (`BroadcastDispatchOffersJob`) and escrow auto-release uses `AutoReleaseEscrowJob`.
- Hybrid Recommendation v2 docs: `docs/Hybrid-Recommendation-v2.md`.

## Feeds (Geo Scope)

Feeds support `scope=local|state|national|auto` (default `auto` for `/api/feed/for-you`). Local results are radius-based (default 10km) and `auto` expands `local → state → national` until the requested page size is filled.

Endpoints:
- `GET /api/feed/near-you` (always local)
- `GET /api/feed/in-your-state`
- `GET /api/feed/across-nigeria`
- `GET /api/feed/for-you`

## Shipping (Non-Local Fulfillment)

Orders include `fulfillment_mode=local_rider|shipping`. Shipping orders use `shipments` (tracking + proofs) and never create rider dispatch jobs.

Seller:
- `POST /api/seller/orders/{id}/shipping/create`
- `POST /api/seller/orders/{id}/shipping/mark-packed`
- `POST /api/seller/orders/{id}/shipping/mark-dropped-off`
- `POST /api/seller/orders/{id}/shipping/update-status`

Buyer:
- `POST /api/orders/{id}/shipping/confirm-delivery` (also works via `POST /api/orders/{id}/confirm-delivery`)

## Post-MVP Features

Assumptions and behavior for pilot hardening:

- Push notifications use FCM legacy API (`FCM_SERVER_KEY`) and broadcast events use Laravel broadcasting (default `log` driver). WebSocket events always emit; push is sent only when `last_seen_at` is older than `PUSH_BACKGROUND_THRESHOLD_MINUTES` or when `forcePush` is used.
- Platform delivery fee credits are recorded to the wallet of `SMARTLINK_PLATFORM_USER_ID`. If this value is unset or invalid, platform fees are not credited (only seller and rider credits are recorded).
- Delivery OTP is optional and controlled by `SMARTLINK_DELIVERY_OTP_REQUIRED`. When enabled, OTP is generated on rider pickup and required at delivery.
- Return window defaults to 48 hours after order confirmation and is enforced by `SMARTLINK_RETURN_WINDOW_HOURS`.
- Return dispatch prefers the last assigned rider, then falls back to zone riders after `SMARTLINK_RETURN_FALLBACK_MINUTES`.
- New account order limit uses `SMARTLINK_NEW_ACCOUNT_MAX_ORDER` and `SMARTLINK_NEW_ACCOUNT_AGE_DAYS`.
- Dispute abuse blocking triggers when a buyer has `SMARTLINK_DISPUTE_ABUSE_THRESHOLD` disputes resolved as `pay_seller`.
