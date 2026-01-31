# Hybrid Recommendation v2 (Smartlink)

This backend implements a “Combined Recommender System v2” that is:
- trust-first (safe defaults, verified shops only)
- cold-start friendly (works without history/metrics)
- stable (deterministic tie-breakers + caching)
- lightweight (no heavy ML)

## Feeds

Public (optional auth supported via bearer token):
- `GET /api/feed/home?zone_id=&lat=&lng=`
- `GET /api/feed/near-you?zone_id=&lat=&lng=`
- `GET /api/feed/trending?zone_id=&days=7`
- `GET /api/feed/top-rated?zone_id=`
- `GET /api/feed/for-you?zone_id=&lat=&lng=`
- `GET /api/feed/ready-soon?zone_id=&lat=&lng=` (food only)

All list endpoints support `page` + `per_page` (max 50).

## Item Shape

Each item:
- `entity_type`: `shop` (MVP)
- `entity_id`
- `title`, `subtitle`
- `image_url` (null for now)
- `score` (0..~1)
- `badges[]`
- `meta{ zone_id, shop_type, is_open, distance_km }`

Dev only (`APP_ENV=local` or `RECOMMENDATIONS_DEBUG=true`):
- `score_breakdown`
- `rank_reason`

## Data Model

Tables:
- `user_events` (lightweight event stream)
- `shop_metrics_daily` (daily aggregates)
- `shop_trust_metrics` (trust-first metrics, 0..100)
- `shop_tags` (simple tagging layer)
- `user_preferences` (derived preferences)
- `user_favorites` (explicit favorites)
- `shop_cooccurrence` (collab-filtering lite pairs)

Shop fields:
- `shops.status`, `shops.is_open`, `shops.operating_hours_json`
- `shops.latitude`, `shops.longitude`

## Jobs + Scheduler

Scheduled in `app/Console/Kernel.php`:
- Daily: aggregate metrics → trust metrics → cooccurrence → preferences
- Hourly: refresh today's shop_metrics_daily for fresher “trending”

## Caching + Stability

`RecommendationService` caches:
- zone feeds: 5 minutes
- for-you: 1 minute
- near-you + ready-soon keys include a ~1km lat/lng bucket

Tie-breaker:
- if scores equal, sort by `shop_id ASC` for stable ordering.

## Diversity Rules

Post-ranking pass enforces:
- max 2 shops per `seller_user_id` in top 10
- max 2 consecutive items with same `shop_type`

## Event Logging

Client can send events:
- `POST /api/events` (optional auth)

Server logs:
- `place_order` (order creation)
- `rate` (seller rating)
- `favorite_shop` (favorites endpoint)

