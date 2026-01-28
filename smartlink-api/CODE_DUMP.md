# Smartlink API Code Dump

This file contains the requested folder structure and the contents of the project files created/edited for the Smartlink MVP backend.

## Folder Structure

```text
smartlink-api
|-- .env.example
|-- README.md
|-- app
|   |-- Domain
|   |   |-- Audit
|   |   |   |-- Models
|   |   |   |   `-- AuditLog.php
|   |   |   `-- Services
|   |   |       `-- AuditLogger.php
|   |   |-- Auth
|   |   |   |-- Controllers
|   |   |   |   |-- AuthController.php
|   |   |   |   `-- OtpController.php
|   |   |   |-- Requests
|   |   |   |   |-- LoginRequest.php
|   |   |   |   |-- OtpSendRequest.php
|   |   |   |   |-- OtpVerifyRequest.php
|   |   |   |   `-- RegisterRequest.php
|   |   |   `-- Services
|   |   |       `-- OtpService.php
|   |   |-- Dispatch
|   |   |   |-- Controllers
|   |   |   |   |-- RiderDispatchController.php
|   |   |   |   |-- RiderOrderFlowController.php
|   |   |   |   `-- SellerDispatchController.php
|   |   |   |-- Enums
|   |   |   |   |-- DispatchJobStatus.php
|   |   |   |   `-- DispatchOfferStatus.php
|   |   |   |-- Jobs
|   |   |   |   `-- BroadcastDispatchOffersJob.php
|   |   |   |-- Models
|   |   |   |   |-- DispatchJob.php
|   |   |   |   |-- DispatchOffer.php
|   |   |   |   `-- SellerRiderPool.php
|   |   |   |-- Policies
|   |   |   |   `-- DispatchJobPolicy.php
|   |   |   |-- Requests
|   |   |   |   `-- ManageRiderPoolRequest.php
|   |   |   |-- Resources
|   |   |   |   `-- DispatchOfferResource.php
|   |   |   `-- Services
|   |   |       `-- DispatchService.php
|   |   |-- Disputes
|   |   |   |-- Controllers
|   |   |   |   `-- AdminDisputeController.php
|   |   |   |-- Enums
|   |   |   |   |-- DisputeReason.php
|   |   |   |   |-- DisputeResolution.php
|   |   |   |   `-- DisputeStatus.php
|   |   |   |-- Models
|   |   |   |   `-- Dispute.php
|   |   |   |-- Requests
|   |   |   |   `-- AdminResolveDisputeRequest.php
|   |   |   `-- Resources
|   |   |       `-- DisputeResource.php
|   |   |-- Escrow
|   |   |   |-- Enums
|   |   |   |   |-- EscrowStatus.php
|   |   |   |   |-- PayoutProvider.php
|   |   |   |   `-- PayoutStatus.php
|   |   |   |-- Jobs
|   |   |   |   `-- AutoReleaseEscrowJob.php
|   |   |   |-- Models
|   |   |   |   |-- EscrowHold.php
|   |   |   |   `-- Payout.php
|   |   |   `-- Services
|   |   |       `-- EscrowService.php
|   |   |-- Evidence
|   |   |   |-- Enums
|   |   |   |   `-- EvidenceType.php
|   |   |   `-- Models
|   |   |       `-- OrderEvidence.php
|   |   |-- Kyc
|   |   |   |-- Controllers
|   |   |   |   |-- AdminKycController.php
|   |   |   |   `-- KycController.php
|   |   |   |-- Enums
|   |   |   |   |-- KycStatus.php
|   |   |   |   `-- KycType.php
|   |   |   |-- Models
|   |   |   |   |-- KycDocument.php
|   |   |   |   `-- KycRequest.php
|   |   |   |-- Requests
|   |   |   |   |-- AdminRejectKycRequest.php
|   |   |   |   `-- SubmitKycRequest.php
|   |   |   |-- Resources
|   |   |   |   `-- KycRequestResource.php
|   |   |   `-- Services
|   |   |       `-- KycService.php
|   |   |-- Notifications
|   |   |   |-- Contracts
|   |   |   |   `-- OtpProvider.php
|   |   |   |-- Jobs
|   |   |   |   `-- SendOtpJob.php
|   |   |   |-- Providers
|   |   |   |   |-- LogOtpProvider.php
|   |   |   |   |-- SendchampOtpProvider.php
|   |   |   |   `-- TermiiOtpProvider.php
|   |   |   `-- Services
|   |   |       `-- NotificationService.php
|   |   |-- Orders
|   |   |   |-- Controllers
|   |   |   |   `-- OrderController.php
|   |   |   |-- Enums
|   |   |   |   |-- OrderPaymentStatus.php
|   |   |   |   `-- OrderStatus.php
|   |   |   |-- Models
|   |   |   |   |-- Order.php
|   |   |   |   |-- OrderItem.php
|   |   |   |   `-- OrderStatusHistory.php
|   |   |   |-- Policies
|   |   |   |   `-- OrderPolicy.php
|   |   |   |-- Requests
|   |   |   |   |-- RaiseDisputeRequest.php
|   |   |   |   `-- StoreOrderRequest.php
|   |   |   |-- Resources
|   |   |   |   |-- OrderItemResource.php
|   |   |   |   `-- OrderResource.php
|   |   |   `-- Services
|   |   |       `-- OrderService.php
|   |   |-- Payments
|   |   |   `-- Services
|   |   |       `-- PaystackService.php
|   |   |-- Products
|   |   |   |-- Controllers
|   |   |   |   |-- PublicProductController.php
|   |   |   |   `-- SellerProductController.php
|   |   |   |-- Enums
|   |   |   |   `-- ProductStatus.php
|   |   |   |-- Models
|   |   |   |   |-- Product.php
|   |   |   |   `-- ProductImage.php
|   |   |   |-- Policies
|   |   |   |   `-- ProductPolicy.php
|   |   |   |-- Requests
|   |   |   |   |-- CreateProductRequest.php
|   |   |   |   `-- UpdateProductRequest.php
|   |   |   `-- Resources
|   |   |       `-- ProductResource.php
|   |   |-- Ratings
|   |   |   |-- Controllers
|   |   |   |   `-- RatingController.php
|   |   |   |-- Enums
|   |   |   |   `-- RateeType.php
|   |   |   |-- Models
|   |   |   |   `-- Rating.php
|   |   |   |-- Requests
|   |   |   |   `-- StoreRatingRequest.php
|   |   |   `-- Resources
|   |   |       `-- RatingResource.php
|   |   |-- Riders
|   |   |   |-- Enums
|   |   |   |   |-- RiderAvailabilityStatus.php
|   |   |   |   `-- VehicleType.php
|   |   |   `-- Models
|   |   |       |-- RiderAvailability.php
|   |   |       `-- RiderProfile.php
|   |   |-- Shops
|   |   |   |-- Controllers
|   |   |   |   |-- PublicShopController.php
|   |   |   |   `-- SellerShopController.php
|   |   |   |-- Enums
|   |   |   |   `-- ShopVerificationPhase.php
|   |   |   |-- Models
|   |   |   |   |-- SellerBankAccount.php
|   |   |   |   `-- Shop.php
|   |   |   |-- Requests
|   |   |   |   `-- CreateShopRequest.php
|   |   |   `-- Resources
|   |   |       `-- ShopResource.php
|   |   |-- Users
|   |   |   |-- Controllers
|   |   |   |   `-- UserZoneController.php
|   |   |   |-- Enums
|   |   |   |   |-- UserRole.php
|   |   |   |   `-- UserStatus.php
|   |   |   |-- Models
|   |   |   |   `-- User.php
|   |   |   |-- Requests
|   |   |   |   `-- SetUserZoneRequest.php
|   |   |   `-- Resources
|   |   |       `-- UserResource.php
|   |   |-- Wallet
|   |   |   |-- Controllers
|   |   |   |   `-- WalletController.php
|   |   |   |-- Enums
|   |   |   |   |-- WalletAccountStatus.php
|   |   |   |   |-- WalletTransactionDirection.php
|   |   |   |   `-- WalletTransactionType.php
|   |   |   |-- Models
|   |   |   |   |-- WalletAccount.php
|   |   |   |   `-- WalletTransaction.php
|   |   |   |-- Requests
|   |   |   |   `-- InitiateTopupRequest.php
|   |   |   |-- Resources
|   |   |   |   |-- WalletAccountResource.php
|   |   |   |   `-- WalletTransactionResource.php
|   |   |   `-- Services
|   |   |       `-- WalletService.php
|   |   |-- Webhooks
|   |   |   `-- Controllers
|   |   |       `-- PaystackWebhookController.php
|   |   `-- Zones
|   |       |-- Controllers
|   |       |   `-- ZoneController.php
|   |       |-- Models
|   |       |   |-- UserZone.php
|   |       |   `-- Zone.php
|   |       `-- Resources
|   |           `-- ZoneResource.php
|   |-- Http
|   |   `-- Middleware
|   |       |-- EnsureRole.php
|   |       `-- EnsureUserStatus.php
|   `-- Providers
|       |-- AppServiceProvider.php
|       `-- AuthServiceProvider.php
|-- bootstrap
|   |-- app.php
|   `-- providers.php
|-- config
|   |-- auth.php
|   |-- cache.php
|   |-- database.php
|   |-- queue.php
|   |-- sanctum.php
|   `-- smartlink.php
|-- database
|   |-- factories
|   |   `-- UserFactory.php
|   |-- migrations
|   |   |-- 0001_01_01_000000_create_users_table.php
|   |   |-- 0001_01_01_000001_create_cache_table.php
|   |   |-- 0001_01_01_000002_create_jobs_table.php
|   |   |-- 2026_01_26_103154_create_personal_access_tokens_table.php
|   |   |-- 2026_01_26_120000_create_smartlink_core_tables.php
|   |   `-- 2026_01_26_130000_add_meta_json_to_kyc_requests.php
|   `-- seeders
|       |-- DatabaseSeeder.php
|       |-- SampleUsersSeeder.php
|       `-- ZonesSeeder.php
|-- phpunit.xml
|-- postman
|   `-- Smartlink.postman_collection.json
|-- routes
|   |-- api.php
|   `-- web.php
`-- tests
    |-- Feature
    |   |-- ConfirmDeliveryReleasesEscrowTest.php
    |   |-- DispatchAcceptTest.php
    |   |-- ExampleTest.php
    |   |-- OrderPlacementTest.php
    |   `-- PaystackWebhookTest.php
    |-- TestCase.php
    `-- Unit
        `-- ExampleTest.php
```

## Files

```dotenv
// .env.example
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_TIMEZONE=UTC
APP_URL=http://localhost

APP_LOCALE=en
APP_FALLBACK_LOCALE=en
APP_FAKER_LOCALE=en_US

APP_MAINTENANCE_DRIVER=file
# APP_MAINTENANCE_STORE=database

PHP_CLI_SERVER_WORKERS=4

BCRYPT_ROUNDS=12

LOG_CHANNEL=stack
LOG_STACK=single
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=sqlite
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=laravel
# DB_USERNAME=root
# DB_PASSWORD=

SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=null

BROADCAST_CONNECTION=log
FILESYSTEM_DISK=local
QUEUE_CONNECTION=redis

CACHE_STORE=redis
CACHE_PREFIX=

MEMCACHED_HOST=127.0.0.1

REDIS_CLIENT=predis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=log
MAIL_SCHEME=null
MAIL_HOST=127.0.0.1
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"

AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINT=false

SMARTLINK_CURRENCY=NGN
SMARTLINK_MEDIA_DISK=${FILESYSTEM_DISK}
SMARTLINK_ESCROW_AUTO_RELEASE_HOURS=24
SMARTLINK_DISPATCH_PRIVATE_POOL_MINUTES=10

PAYSTACK_SECRET_KEY=
PAYSTACK_BASE_URL=https://api.paystack.co

OTP_DRIVER=log
OTP_SENDER_ID=Smartlink
TERMII_API_KEY=
TERMII_BASE_URL=https://api.ng.termii.com
SENDCHAMP_API_KEY=
SENDCHAMP_BASE_URL=https://api.sendchamp.com/api/v1

VITE_APP_NAME="${APP_NAME}"

```

```markdown
<!-- README.md -->
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


```

```php
<?php

// app/Domain/Audit/Models/AuditLog.php

namespace App\Domain\Audit\Models;

use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AuditLog extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'meta_json' => 'array',
        ];
    }

    public function actor()
    {
        return $this->belongsTo(User::class, 'actor_user_id');
    }
}

```

```php
<?php

// app/Domain/Audit/Services/AuditLogger.php

namespace App\Domain\Audit\Services;

use App\Domain\Audit\Models\AuditLog;
use Illuminate\Database\Eloquent\Model;

class AuditLogger
{
    /**
     * @param  array<string, mixed>  $meta
     */
    public function log(
        ?int $actorUserId,
        string $action,
        ?Model $auditable = null,
        array $meta = [],
    ): void {
        $req = request();

        AuditLog::create([
            'actor_user_id' => $actorUserId,
            'action' => $action,
            'auditable_type' => $auditable ? $auditable::class : null,
            'auditable_id' => $auditable?->getKey(),
            'ip_address' => $req?->ip(),
            'user_agent' => $req?->userAgent(),
            'meta_json' => $meta === [] ? null : $meta,
        ]);
    }
}

```

```php
<?php

// app/Domain/Auth/Controllers/AuthController.php

namespace App\Domain\Auth\Controllers;

use App\Domain\Auth\Requests\LoginRequest;
use App\Domain\Auth\Requests\RegisterRequest;
use App\Domain\Auth\Services\OtpService;
use App\Domain\Notifications\Jobs\SendOtpJob;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Users\Resources\UserResource;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

class AuthController
{
    public function register(RegisterRequest $request, OtpService $otpService)
    {
        $data = $request->validated();

        /** @var User $user */
        $user = DB::transaction(function () use ($data): User {
            return User::create([
                'full_name' => $data['full_name'],
                'phone' => $data['phone'],
                'email' => $data['email'] ?? null,
                'password' => $data['password'],
                'role' => UserRole::from($data['role'] ?? UserRole::Buyer->value),
                'status' => UserStatus::Pending,
            ]);
        });

        if (! $user->hasVerifiedPhone()) {
            $code = $otpService->generateCode();
            $otpService->store($user->phone, 'verify_phone', $code);
            dispatch(new SendOtpJob($user->phone, $code, $otpService->ttlMinutes()));
        }

        $token = $user->createToken((string) ($data['device_name'] ?? 'mobile'))->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => new UserResource($user),
        ], 201);
    }

    public function login(LoginRequest $request)
    {
        $data = $request->validated();

        $user = User::query()
            ->when(isset($data['phone']), fn ($q) => $q->where('phone', $data['phone']))
            ->when(! isset($data['phone']) && isset($data['email']), fn ($q) => $q->where('email', $data['email']))
            ->first();

        if (! $user || ! Hash::check((string) $data['password'], (string) $user->password)) {
            return response()->json(['message' => 'Invalid credentials.'], 422);
        }

        if (in_array($user->status->value, ['suspended', 'banned'], true)) {
            return response()->json(['message' => 'Account is not active.'], 403);
        }

        $token = $user->createToken((string) ($data['device_name'] ?? 'mobile'))->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => new UserResource($user),
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()?->currentAccessToken()?->delete();

        return response()->json(['message' => 'Logged out.']);
    }

    public function me(Request $request)
    {
        return new UserResource($request->user());
    }
}

```

```php
<?php

// app/Domain/Auth/Controllers/OtpController.php

namespace App\Domain\Auth\Controllers;

use App\Domain\Auth\Requests\OtpSendRequest;
use App\Domain\Auth\Requests\OtpVerifyRequest;
use App\Domain\Auth\Services\OtpService;
use App\Domain\Notifications\Jobs\SendOtpJob;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Users\Resources\UserResource;
use Illuminate\Support\Facades\DB;

class OtpController
{
    public function send(OtpSendRequest $request, OtpService $otpService)
    {
        $data = $request->validated();

        /** @var User $user */
        $user = User::where('phone', $data['phone'])->firstOrFail();

        $code = $otpService->generateCode();
        $otpService->store($user->phone, $data['purpose'], $code);

        dispatch(new SendOtpJob($user->phone, $code, $otpService->ttlMinutes()));

        return response()->json(['message' => 'OTP sent.']);
    }

    public function verify(OtpVerifyRequest $request, OtpService $otpService)
    {
        $data = $request->validated();

        /** @var User $user */
        $user = User::where('phone', $data['phone'])->firstOrFail();

        if (! $otpService->verify($user->phone, $data['purpose'], $data['code'])) {
            return response()->json(['message' => 'Invalid or expired OTP.'], 422);
        }

        DB::transaction(function () use ($user): void {
            $user->forceFill(['phone_verified_at' => now()])->save();

            if ($user->role === UserRole::Buyer && $user->status === UserStatus::Pending) {
                $user->forceFill(['status' => UserStatus::Active])->save();
            }
        });

        $otpService->consume($user->phone, $data['purpose']);

        return new UserResource($user->fresh());
    }
}

```

```php
<?php

// app/Domain/Auth/Requests/LoginRequest.php

namespace App\Domain\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'phone' => ['nullable', 'string', 'max:32'],
            'email' => ['nullable', 'email', 'max:255'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:255'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $phone = (string) $this->input('phone', '');
            $email = (string) $this->input('email', '');

            if ($phone === '' && $email === '') {
                $validator->errors()->add('phone', 'Phone or email is required.');
            }
        });
    }
}

```

```php
<?php

// app/Domain/Auth/Requests/OtpSendRequest.php

namespace App\Domain\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class OtpSendRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'phone' => ['required', 'string', 'max:32', 'exists:users,phone'],
            'purpose' => ['required', 'string', Rule::in(['verify_phone'])],
        ];
    }
}

```

```php
<?php

// app/Domain/Auth/Requests/OtpVerifyRequest.php

namespace App\Domain\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class OtpVerifyRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'phone' => ['required', 'string', 'max:32', 'exists:users,phone'],
            'purpose' => ['required', 'string', Rule::in(['verify_phone'])],
            'code' => ['required', 'string', 'regex:/^[0-9]{6}$/'],
        ];
    }
}

```

```php
<?php

// app/Domain/Auth/Requests/RegisterRequest.php

namespace App\Domain\Auth\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'full_name' => ['required', 'string', 'max:255'],
            'phone' => ['required', 'string', 'max:32', 'regex:/^[0-9+\\-\\s]+$/', 'unique:users,phone'],
            'email' => ['nullable', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8'],
            'role' => ['nullable', 'string', Rule::in(['buyer', 'seller', 'rider'])],
            'device_name' => ['nullable', 'string', 'max:255'],
        ];
    }
}

```

```php
<?php

// app/Domain/Auth/Services/OtpService.php

namespace App\Domain\Auth\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class OtpService
{
    public function generateCode(): string
    {
        return (string) random_int(100000, 999999);
    }

    public function ttlMinutes(): int
    {
        return 5;
    }

    public function store(string $phone, string $purpose, string $code): void
    {
        Cache::put(
            $this->cacheKey($phone, $purpose),
            [
                'hash' => Hash::make($code),
                'attempts' => 0,
                'nonce' => Str::uuid()->toString(),
            ],
            now()->addMinutes($this->ttlMinutes()),
        );
    }

    public function verify(string $phone, string $purpose, string $code): bool
    {
        $key = $this->cacheKey($phone, $purpose);
        $payload = Cache::get($key);

        if (! is_array($payload) || ! isset($payload['hash'])) {
            return false;
        }

        $attempts = (int) ($payload['attempts'] ?? 0);
        if ($attempts >= 5) {
            Cache::forget($key);
            return false;
        }

        $ok = Hash::check($code, (string) $payload['hash']);

        if (! $ok) {
            $payload['attempts'] = $attempts + 1;
            Cache::put($key, $payload, now()->addMinutes($this->ttlMinutes()));
        }

        return $ok;
    }

    public function consume(string $phone, string $purpose): void
    {
        Cache::forget($this->cacheKey($phone, $purpose));
    }

    private function cacheKey(string $phone, string $purpose): string
    {
        return 'otp:'.preg_replace('/\\s+/', '', $phone).':'.$purpose;
    }
}

```

```php
<?php

// app/Domain/Dispatch/Controllers/RiderDispatchController.php

namespace App\Domain\Dispatch\Controllers;

use App\Domain\Dispatch\Resources\DispatchOfferResource;
use App\Domain\Dispatch\Services\DispatchService;
use Illuminate\Http\Request;

class RiderDispatchController
{
    public function __construct(private readonly DispatchService $dispatchService)
    {
    }

    public function offers(Request $request)
    {
        $offers = $this->dispatchService->offersForRider($request->user());

        return DispatchOfferResource::collection($offers);
    }

    public function accept(Request $request, int $offerId)
    {
        try {
            $job = $this->dispatchService->acceptOffer($request->user(), $offerId);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        }

        return response()->json([
            'dispatch_job_id' => $job->id,
            'status' => $job->status->value,
            'assigned_rider_user_id' => $job->assigned_rider_user_id,
        ]);
    }

    public function decline(Request $request, int $offerId)
    {
        try {
            $offer = $this->dispatchService->declineOffer($request->user(), $offerId);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 409);
        }

        return new DispatchOfferResource($offer->load('job.order'));
    }
}

```

```php
<?php

// app/Domain/Dispatch/Controllers/RiderOrderFlowController.php

namespace App\Domain\Dispatch\Controllers;

use App\Domain\Dispatch\Services\DispatchService;
use App\Domain\Orders\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class RiderOrderFlowController
{
    public function __construct(private readonly DispatchService $dispatchService)
    {
    }

    public function uploadPickupProof(Request $request, Order $order)
    {
        $request->validate([
            'video' => ['required', 'file', 'mimetypes:video/mp4,video/quicktime,video/x-matroska', 'max:51200'],
        ]);

        $disk = (string) config('smartlink.media_disk', 'local');
        $file = $request->file('video');

        $path = Storage::disk($disk)->putFileAs(
            "orders/{$order->id}/evidence",
            $file,
            'pickup-'.Str::uuid()->toString().'.'.$file->getClientOriginalExtension(),
        );

        try {
            $evidence = $this->dispatchService->uploadPickupProof(
                $request->user(),
                $order,
                Storage::disk($disk)->url($path),
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 403);
        }

        return response()->json([
            'id' => $evidence->id,
            'file_url' => $evidence->file_url,
        ]);
    }

    public function markPickedUp(Request $request, Order $order)
    {
        try {
            $updated = $this->dispatchService->markPickedUp($request->user(), $order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json(['message' => 'Marked as picked up.', 'status' => $updated->status->value]);
    }

    public function markDelivered(Request $request, Order $order)
    {
        try {
            $updated = $this->dispatchService->markDelivered($request->user(), $order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Marked as delivered.',
            'status' => $updated->status->value,
            'escrow_hold_expires_at' => optional($updated->escrowHold?->hold_expires_at)?->toISOString(),
        ]);
    }
}

```

```php
<?php

// app/Domain/Dispatch/Controllers/SellerDispatchController.php

namespace App\Domain\Dispatch\Controllers;

use App\Domain\Dispatch\Models\SellerRiderPool;
use App\Domain\Dispatch\Requests\ManageRiderPoolRequest;
use App\Domain\Dispatch\Services\DispatchService;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Users\Models\User;
use Illuminate\Support\Facades\Gate;

class SellerDispatchController
{
    public function __construct(private readonly DispatchService $dispatchService)
    {
    }

    public function orders()
    {
        $seller = request()->user();
        $shopId = $seller->shop?->id;

        $orders = Order::query()
            ->where('shop_id', $shopId ?? 0)
            ->latest('id')
            ->paginate(20);

        return OrderResource::collection($orders);
    }

    public function addRiderToPool(ManageRiderPoolRequest $request)
    {
        $seller = $request->user();
        $shopId = $seller->shop?->id;
        if (! $shopId) {
            return response()->json(['message' => 'Create a shop first.'], 422);
        }
        $data = $request->validated();

        /** @var User $rider */
        $rider = User::query()->whereKey($data['rider_user_id'])->firstOrFail();
        if ($rider->role->value !== 'rider' || $rider->status->value !== 'active') {
            return response()->json(['message' => 'Rider must be active.'], 422);
        }

        if (! RiderAvailability::query()->where('rider_user_id', $rider->id)->exists()) {
            return response()->json(['message' => 'Rider profile not found.'], 422);
        }

        $record = SellerRiderPool::updateOrCreate(
            ['shop_id' => $shopId, 'rider_user_id' => $rider->id],
            ['status' => 'active', 'added_by' => $seller->id],
        );

        return response()->json(['message' => 'Rider added.', 'id' => $record->id]);
    }

    public function removeRiderFromPool(ManageRiderPoolRequest $request)
    {
        $seller = $request->user();
        $shopId = $seller->shop?->id;
        if (! $shopId) {
            return response()->json(['message' => 'Create a shop first.'], 422);
        }
        $data = $request->validated();

        SellerRiderPool::query()
            ->where('shop_id', $shopId)
            ->where('rider_user_id', $data['rider_user_id'])
            ->update(['status' => 'removed', 'added_by' => $seller->id]);

        return response()->json(['message' => 'Rider removed.']);
    }

    public function dispatch(Order $order)
    {
        $seller = request()->user();
        Gate::authorize('dispatch', $order);

        try {
            $job = $this->dispatchService->dispatchOrder($seller, $order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'dispatch_job_id' => $job->id,
            'status' => $job->status->value,
            'private_pool_only_until' => optional($job->private_pool_only_until)?->toISOString(),
            'fallback_broadcast_at' => optional($job->fallback_broadcast_at)?->toISOString(),
        ]);
    }
}
```

```php
<?php

// app/Domain/Dispatch/Enums/DispatchJobStatus.php

namespace App\Domain\Dispatch\Enums;

enum DispatchJobStatus: string
{
    case Pending = 'pending';
    case Broadcasting = 'broadcasting';
    case Assigned = 'assigned';
    case Expired = 'expired';
    case Cancelled = 'cancelled';
}

```

```php
<?php

// app/Domain/Dispatch/Enums/DispatchOfferStatus.php

namespace App\Domain\Dispatch\Enums;

enum DispatchOfferStatus: string
{
    case Sent = 'sent';
    case Seen = 'seen';
    case Accepted = 'accepted';
    case Declined = 'declined';
    case Expired = 'expired';
}

```

```php
<?php

// app/Domain/Dispatch/Jobs/BroadcastDispatchOffersJob.php

namespace App\Domain\Dispatch\Jobs;

use App\Domain\Dispatch\Services\DispatchService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class BroadcastDispatchOffersJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(public readonly int $dispatchJobId, public readonly string $mode)
    {
    }

    public function handle(DispatchService $dispatchService): void
    {
        $dispatchService->broadcastOffers($this->dispatchJobId, $this->mode);
    }
}

```

```php
<?php

// app/Domain/Dispatch/Models/DispatchJob.php

namespace App\Domain\Dispatch\Models;

use App\Domain\Dispatch\Enums\DispatchJobStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DispatchJob extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'status' => DispatchJobStatus::class,
            'private_pool_only_until' => 'datetime',
            'fallback_broadcast_at' => 'datetime',
        ];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function assignedRider()
    {
        return $this->belongsTo(User::class, 'assigned_rider_user_id');
    }

    public function offers()
    {
        return $this->hasMany(DispatchOffer::class);
    }
}

```

```php
<?php

// app/Domain/Dispatch/Models/DispatchOffer.php

namespace App\Domain\Dispatch\Models;

use App\Domain\Dispatch\Enums\DispatchOfferStatus;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DispatchOffer extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'offer_status' => DispatchOfferStatus::class,
            'offered_at' => 'datetime',
            'responded_at' => 'datetime',
        ];
    }

    public function job()
    {
        return $this->belongsTo(DispatchJob::class, 'dispatch_job_id');
    }

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_user_id');
    }
}

```

```php
<?php

// app/Domain/Dispatch/Models/SellerRiderPool.php

namespace App\Domain\Dispatch\Models;

use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SellerRiderPool extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_user_id');
    }

    public function addedBy()
    {
        return $this->belongsTo(User::class, 'added_by');
    }
}

```

```php
<?php

// app/Domain/Dispatch/Policies/DispatchJobPolicy.php

namespace App\Domain\Dispatch\Policies;

use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Models\User;

class DispatchJobPolicy
{
    public function view(User $user, DispatchJob $dispatchJob): bool
    {
        if ($user->role === UserRole::Admin) {
            return true;
        }

        if ($user->role === UserRole::Seller) {
            return (int) $dispatchJob->shop_id === (int) ($user->shop?->id ?? 0);
        }

        if ($user->role === UserRole::Rider) {
            return (int) ($dispatchJob->assigned_rider_user_id ?? 0) === (int) $user->id;
        }

        return false;
    }
}

```

```php
<?php

// app/Domain/Dispatch/Requests/ManageRiderPoolRequest.php

namespace App\Domain\Dispatch\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ManageRiderPoolRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'rider_user_id' => ['required', 'integer', 'exists:users,id'],
        ];
    }
}

```

```php
<?php

// app/Domain/Dispatch/Resources/DispatchOfferResource.php

namespace App\Domain\Dispatch\Resources;

use App\Domain\Orders\Resources\OrderResource;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DispatchOfferResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Dispatch\Models\DispatchOffer $offer */
        $offer = $this->resource;

        return [
            'id' => $offer->id,
            'dispatch_job_id' => $offer->dispatch_job_id,
            'rider_user_id' => $offer->rider_user_id,
            'offer_status' => $offer->offer_status->value,
            'offered_at' => optional($offer->offered_at)?->toISOString(),
            'responded_at' => optional($offer->responded_at)?->toISOString(),
            'order' => $offer->relationLoaded('job') && $offer->job?->relationLoaded('order')
                ? new OrderResource($offer->job->order->loadMissing(['items', 'escrowHold']))
                : null,
        ];
    }
}

```

```php
<?php

// app/Domain/Dispatch/Services/DispatchService.php

namespace App\Domain\Dispatch\Services;

use App\Domain\Dispatch\Enums\DispatchJobStatus;
use App\Domain\Dispatch\Enums\DispatchOfferStatus;
use App\Domain\Dispatch\Jobs\BroadcastDispatchOffersJob;
use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Dispatch\Models\DispatchOffer;
use App\Domain\Dispatch\Models\SellerRiderPool;
use App\Domain\Escrow\Jobs\AutoReleaseEscrowJob;
use App\Domain\Evidence\Enums\EvidenceType;
use App\Domain\Evidence\Models\OrderEvidence;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Riders\Enums\RiderAvailabilityStatus;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Database\QueryException;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class DispatchService
{
    public function dispatchOrder(User $seller, Order $order): DispatchJob
    {
        return DB::transaction(function () use ($seller, $order): DispatchJob {
            /** @var Order $lockedOrder */
            $lockedOrder = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ((int) $lockedOrder->shop_id !== (int) ($seller->shop?->id ?? 0)) {
                throw new \RuntimeException('Forbidden.');
            }

            if (! in_array($lockedOrder->status, [OrderStatus::Paid, OrderStatus::AcceptedBySeller], true)) {
                throw new \RuntimeException('Order is not dispatchable.');
            }

            if ($lockedOrder->status === OrderStatus::Paid) {
                $lockedOrder->forceFill(['status' => OrderStatus::AcceptedBySeller])->save();
                $this->appendHistory($lockedOrder, OrderStatus::AcceptedBySeller, $seller->id);
            }

            $lockedOrder->forceFill(['status' => OrderStatus::Dispatching])->save();
            $this->appendHistory($lockedOrder, OrderStatus::Dispatching, $seller->id);

            $minutes = (int) config('smartlink.dispatch.private_pool_minutes', 10);
            $now = now();

            $job = DispatchJob::firstOrCreate(
                ['order_id' => $lockedOrder->id],
                [
                    'shop_id' => $lockedOrder->shop_id,
                    'zone_id' => $lockedOrder->zone_id,
                    'status' => DispatchJobStatus::Broadcasting,
                    'assigned_rider_user_id' => null,
                    'private_pool_only_until' => $now->copy()->addMinutes($minutes),
                    'fallback_broadcast_at' => $now->copy()->addMinutes($minutes),
                ],
            );

            // Broadcast to private pool immediately.
            dispatch(new BroadcastDispatchOffersJob($job->id, 'private'));

            // Fallback broadcast after window.
            dispatch((new BroadcastDispatchOffersJob($job->id, 'fallback'))->delay($now->copy()->addMinutes($minutes)));

            return $job->fresh();
        });
    }

    public function broadcastOffers(int $dispatchJobId, string $mode): void
    {
        /** @var DispatchJob $job */
        $job = DispatchJob::query()->with(['order'])->findOrFail($dispatchJobId);

        if ($job->status === DispatchJobStatus::Assigned) {
            return;
        }

        if ($mode === 'private') {
            $riderIds = SellerRiderPool::query()
                ->where('shop_id', $job->shop_id)
                ->where('status', 'active')
                ->pluck('rider_user_id')
                ->all();
        } elseif ($mode === 'fallback') {
            $riderIds = $this->getAvailableRidersInZone($job->zone_id);
        } else {
            throw new \InvalidArgumentException('Invalid broadcast mode.');
        }

        if ($riderIds === []) {
            return;
        }

        $availableRiderIds = $this->filterAvailableRiders($riderIds, $job->zone_id);

        foreach ($availableRiderIds as $riderId) {
            try {
                DispatchOffer::create([
                    'dispatch_job_id' => $job->id,
                    'rider_user_id' => $riderId,
                    'offer_status' => DispatchOfferStatus::Sent,
                    'offered_at' => now(),
                    'responded_at' => null,
                ]);
            } catch (QueryException $e) {
                // Ignore duplicates (idempotent broadcast).
            }
        }
    }

    public function offersForRider(User $rider)
    {
        return DispatchOffer::query()
            ->with(['job.order.items', 'job.order.escrowHold'])
            ->where('rider_user_id', $rider->id)
            ->whereIn('offer_status', [DispatchOfferStatus::Sent, DispatchOfferStatus::Seen])
            ->orderByDesc('id')
            ->paginate(20);
    }

    public function acceptOffer(User $rider, int $offerId): DispatchJob
    {
        return DB::transaction(function () use ($rider, $offerId): DispatchJob {
            /** @var DispatchOffer $offer */
            $offer = DispatchOffer::query()->whereKey($offerId)->lockForUpdate()->firstOrFail();

            if ((int) $offer->rider_user_id !== (int) $rider->id) {
                throw new \RuntimeException('Forbidden.');
            }

            if (! in_array($offer->offer_status, [DispatchOfferStatus::Sent, DispatchOfferStatus::Seen], true)) {
                throw new \RuntimeException('Offer is not acceptible.');
            }

            /** @var DispatchJob $job */
            $job = DispatchJob::query()->whereKey($offer->dispatch_job_id)->lockForUpdate()->firstOrFail();

            if ($job->status === DispatchJobStatus::Assigned) {
                throw new \RuntimeException('Dispatch job already assigned.');
            }

            $job->forceFill([
                'status' => DispatchJobStatus::Assigned,
                'assigned_rider_user_id' => $rider->id,
            ])->save();

            $offer->forceFill([
                'offer_status' => DispatchOfferStatus::Accepted,
                'responded_at' => now(),
            ])->save();

            DispatchOffer::query()
                ->where('dispatch_job_id', $job->id)
                ->where('id', '!=', $offer->id)
                ->whereIn('offer_status', [DispatchOfferStatus::Sent, DispatchOfferStatus::Seen])
                ->update(['offer_status' => DispatchOfferStatus::Expired->value]);

            /** @var Order $order */
            $order = Order::query()->whereKey($job->order_id)->lockForUpdate()->firstOrFail();
            $order->forceFill(['status' => OrderStatus::AssignedToRider])->save();
            $this->appendHistory($order, OrderStatus::AssignedToRider, $rider->id);

            RiderAvailability::query()
                ->where('rider_user_id', $rider->id)
                ->update(['status' => RiderAvailabilityStatus::Busy->value, 'last_seen_at' => now()]);

            return $job->fresh();
        });
    }

    public function declineOffer(User $rider, int $offerId): DispatchOffer
    {
        return DB::transaction(function () use ($rider, $offerId) {
            /** @var DispatchOffer $offer */
            $offer = DispatchOffer::query()->whereKey($offerId)->lockForUpdate()->firstOrFail();

            if ((int) $offer->rider_user_id !== (int) $rider->id) {
                throw new \RuntimeException('Forbidden.');
            }

            if (! in_array($offer->offer_status, [DispatchOfferStatus::Sent, DispatchOfferStatus::Seen], true)) {
                return $offer;
            }

            $offer->forceFill([
                'offer_status' => DispatchOfferStatus::Declined,
                'responded_at' => now(),
            ])->save();

            return $offer->fresh();
        });
    }

    public function uploadPickupProof(User $rider, Order $order, string $fileUrl): OrderEvidence
    {
        $this->assertAssignedRider($rider, $order);

        return OrderEvidence::create([
            'order_id' => $order->id,
            'type' => EvidenceType::PickupVideo,
            'file_url' => $fileUrl,
            'captured_by_user_id' => $rider->id,
        ]);
    }

    public function markPickedUp(User $rider, Order $order): Order
    {
        $this->assertAssignedRider($rider, $order);

        return DB::transaction(function () use ($rider, $order) {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === OrderStatus::PickedUp) {
                return $locked;
            }

            if ($locked->status !== OrderStatus::AssignedToRider) {
                throw new \RuntimeException('Order is not ready for pickup.');
            }

            $hasProof = OrderEvidence::query()
                ->where('order_id', $locked->id)
                ->where('type', EvidenceType::PickupVideo)
                ->where('captured_by_user_id', $rider->id)
                ->exists();

            if (! $hasProof) {
                throw new \RuntimeException('Pickup proof is required.');
            }

            $locked->forceFill(['status' => OrderStatus::PickedUp])->save();
            $this->appendHistory($locked, OrderStatus::PickedUp, $rider->id);

            return $locked->fresh();
        });
    }

    public function markDelivered(User $rider, Order $order, ?Carbon $holdExpiresAt = null): Order
    {
        $this->assertAssignedRider($rider, $order);

        return DB::transaction(function () use ($rider, $order, $holdExpiresAt) {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === OrderStatus::Delivered) {
                return $locked->fresh(['escrowHold']);
            }

            if ($locked->status !== OrderStatus::PickedUp) {
                throw new \RuntimeException('Order is not picked up.');
            }

            $locked->forceFill(['status' => OrderStatus::Delivered])->save();
            $this->appendHistory($locked, OrderStatus::Delivered, $rider->id);

            $hold = $locked->escrowHold()->lockForUpdate()->firstOrFail();
            if (! $hold->hold_expires_at) {
                $expiresAt = $holdExpiresAt ?: now()->addHours((int) config('smartlink.escrow.auto_release_hours', 24));
                $hold->forceFill(['hold_expires_at' => $expiresAt])->save();
                dispatch((new AutoReleaseEscrowJob($hold->id))->delay($expiresAt)->afterCommit());
            }

            RiderAvailability::query()
                ->where('rider_user_id', $rider->id)
                ->update(['status' => RiderAvailabilityStatus::Available->value, 'last_seen_at' => now()]);

            return $locked->fresh(['escrowHold']);
        });
    }

    private function assertAssignedRider(User $rider, Order $order): void
    {
        $job = DispatchJob::query()->where('order_id', $order->id)->first();

        if (! $job || (int) $job->assigned_rider_user_id !== (int) $rider->id) {
            throw new \RuntimeException('Forbidden.');
        }
    }

    /**
     * @param  list<int>  $riderIds
     * @return list<int>
     */
    private function filterAvailableRiders(array $riderIds, int $zoneId): array
    {
        $ridersInZone = UserZone::query()
            ->whereIn('user_id', $riderIds)
            ->where('type', 'operational')
            ->where('zone_id', $zoneId)
            ->pluck('user_id')
            ->all();

        return RiderAvailability::query()
            ->whereIn('rider_user_id', $ridersInZone)
            ->where('status', RiderAvailabilityStatus::Available->value)
            ->pluck('rider_user_id')
            ->map(fn ($id) => (int) $id)
            ->all();
    }

    /**
     * @return list<int>
     */
    private function getAvailableRidersInZone(int $zoneId): array
    {
        $riderIds = User::query()
            ->where('role', 'rider')
            ->where('status', 'active')
            ->pluck('id')
            ->all();

        return $this->filterAvailableRiders($riderIds, $zoneId);
    }

    private function appendHistory(Order $order, OrderStatus $status, ?int $changedByUserId): void
    {
        OrderStatusHistory::create([
            'order_id' => $order->id,
            'status' => $status->value,
            'changed_by_user_id' => $changedByUserId,
        ]);
    }
}
```

```php
<?php

// app/Domain/Disputes/Controllers/AdminDisputeController.php

namespace App\Domain\Disputes\Controllers;

use App\Domain\Disputes\Enums\DisputeResolution;
use App\Domain\Disputes\Enums\DisputeStatus;
use App\Domain\Disputes\Models\Dispute;
use App\Domain\Disputes\Requests\AdminResolveDisputeRequest;
use App\Domain\Disputes\Resources\DisputeResource;
use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Support\Facades\DB;

class AdminDisputeController
{
    public function __construct(
        private readonly EscrowService $escrowService,
        private readonly WalletService $walletService,
    ) {
    }

    public function resolve(AdminResolveDisputeRequest $request, Order $order)
    {
        $admin = $request->user();
        $data = $request->validated();

        /** @var Dispute|null $dispute */
        $dispute = Dispute::query()->where('order_id', $order->id)->first();
        if (! $dispute) {
            return response()->json(['message' => 'Dispute not found.'], 404);
        }

        $resolution = DisputeResolution::from($data['resolution']);

        $resolved = DB::transaction(function () use ($order, $dispute, $admin, $resolution, $data) {
            /** @var Dispute $lockedDispute */
            $lockedDispute = Dispute::query()->whereKey($dispute->id)->lockForUpdate()->firstOrFail();

            if ($lockedDispute->status === DisputeStatus::Resolved) {
                return $lockedDispute;
            }

            /** @var Order $lockedOrder */
            $lockedOrder = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            $hold = $lockedOrder->escrowHold()->lockForUpdate()->firstOrFail();

            if ($resolution === DisputeResolution::PaySeller) {
                if ($hold->status === EscrowStatus::Held || $hold->status === EscrowStatus::Frozen) {
                    $this->escrowService->release($hold, $admin->id);
                }

                $lockedOrder->forceFill(['status' => OrderStatus::Confirmed])->save();
                $this->appendHistory($lockedOrder, OrderStatus::Confirmed, $admin->id);
            } elseif ($resolution === DisputeResolution::PartialRefund) {
                $refundAmount = (float) ($data['partial_refund_amount'] ?? 0);
                if ($refundAmount <= 0 || $refundAmount >= (float) $hold->amount) {
                    throw new \RuntimeException('Invalid partial_refund_amount.');
                }

                $releaseAmount = (float) $hold->amount - $refundAmount;

                $buyerWallet = $hold->buyerWalletAccount()->lockForUpdate()->firstOrFail();
                $sellerWallet = $this->walletService->walletFor($hold->seller()->firstOrFail());

                $this->walletService->record(
                    $buyerWallet,
                    WalletTransactionType::Refund,
                    WalletTransactionDirection::In,
                    $refundAmount,
                    "escrow:order:{$lockedOrder->id}:partial_refund",
                    relatedEntityType: 'orders',
                    relatedEntityId: $lockedOrder->id,
                    meta: ['actor_user_id' => $admin->id],
                );

                $this->walletService->record(
                    $sellerWallet,
                    WalletTransactionType::Release,
                    WalletTransactionDirection::In,
                    $releaseAmount,
                    "escrow:order:{$lockedOrder->id}:partial_release",
                    relatedEntityType: 'orders',
                    relatedEntityId: $lockedOrder->id,
                    meta: ['actor_user_id' => $admin->id],
                );

                $hold->forceFill(['status' => EscrowStatus::Released])->save();

                $lockedOrder->forceFill(['status' => OrderStatus::Confirmed])->save();
                $this->appendHistory($lockedOrder, OrderStatus::Confirmed, $admin->id);
            } else {
                // refund_buyer / penalize_* -> refund buyer
                if ($hold->status === EscrowStatus::Held || $hold->status === EscrowStatus::Frozen) {
                    $this->escrowService->refund($hold, $admin->id);
                }

                $lockedOrder->forceFill([
                    'status' => OrderStatus::Cancelled,
                    'payment_status' => OrderPaymentStatus::Refunded,
                ])->save();

                $this->appendHistory($lockedOrder, OrderStatus::Cancelled, $admin->id);
            }

            $lockedDispute->forceFill([
                'status' => DisputeStatus::Resolved,
                'resolved_by_admin_id' => $admin->id,
                'resolution' => $resolution,
            ])->save();

            return $lockedDispute->fresh();
        });

        return new DisputeResource($resolved);
    }

    private function appendHistory(Order $order, OrderStatus $status, ?int $changedByUserId): void
    {
        OrderStatusHistory::create([
            'order_id' => $order->id,
            'status' => $status->value,
            'changed_by_user_id' => $changedByUserId,
        ]);
    }
}

```

```php
<?php

// app/Domain/Disputes/Enums/DisputeReason.php

namespace App\Domain\Disputes\Enums;

enum DisputeReason: string
{
    case WrongItem = 'wrong_item';
    case DamagedItem = 'damaged_item';
    case NotDelivered = 'not_delivered';
    case Other = 'other';
}

```

```php
<?php

// app/Domain/Disputes/Enums/DisputeResolution.php

namespace App\Domain\Disputes\Enums;

enum DisputeResolution: string
{
    case RefundBuyer = 'refund_buyer';
    case PaySeller = 'pay_seller';
    case PartialRefund = 'partial_refund';
    case PenalizeRider = 'penalize_rider';
    case PenalizeSeller = 'penalize_seller';
}

```

```php
<?php

// app/Domain/Disputes/Enums/DisputeStatus.php

namespace App\Domain\Disputes\Enums;

enum DisputeStatus: string
{
    case Open = 'open';
    case UnderReview = 'under_review';
    case Resolved = 'resolved';
    case Rejected = 'rejected';
}

```

```php
<?php

// app/Domain/Disputes/Models/Dispute.php

namespace App\Domain\Disputes\Models;

use App\Domain\Disputes\Enums\DisputeReason;
use App\Domain\Disputes\Enums\DisputeResolution;
use App\Domain\Disputes\Enums\DisputeStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Dispute extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'reason' => DisputeReason::class,
            'status' => DisputeStatus::class,
            'resolution' => DisputeResolution::class,
        ];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function raisedBy()
    {
        return $this->belongsTo(User::class, 'raised_by_user_id');
    }

    public function resolvedBy()
    {
        return $this->belongsTo(User::class, 'resolved_by_admin_id');
    }
}

```

```php
<?php

// app/Domain/Disputes/Requests/AdminResolveDisputeRequest.php

namespace App\Domain\Disputes\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class AdminResolveDisputeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'resolution' => ['required', 'string', Rule::in([
                'refund_buyer',
                'pay_seller',
                'partial_refund',
                'penalize_rider',
                'penalize_seller',
            ])],
            'partial_refund_amount' => ['nullable', 'numeric', 'min:0.01'],
        ];
    }
}

```

```php
<?php

// app/Domain/Disputes/Resources/DisputeResource.php

namespace App\Domain\Disputes\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DisputeResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Disputes\Models\Dispute $dispute */
        $dispute = $this->resource;

        return [
            'id' => $dispute->id,
            'order_id' => $dispute->order_id,
            'raised_by_user_id' => $dispute->raised_by_user_id,
            'reason' => $dispute->reason->value,
            'description' => $dispute->description,
            'status' => $dispute->status->value,
            'resolution' => $dispute->resolution?->value,
            'created_at' => optional($dispute->created_at)?->toISOString(),
        ];
    }
}

```

```php
<?php

// app/Domain/Escrow/Enums/EscrowStatus.php

namespace App\Domain\Escrow\Enums;

enum EscrowStatus: string
{
    case Held = 'held';
    case Released = 'released';
    case Frozen = 'frozen';
    case Refunded = 'refunded';
}

```

```php
<?php

// app/Domain/Escrow/Enums/PayoutProvider.php

namespace App\Domain\Escrow\Enums;

enum PayoutProvider: string
{
    case Paystack = 'paystack';
    case Flutterwave = 'flutterwave';
}

```

```php
<?php

// app/Domain/Escrow/Enums/PayoutStatus.php

namespace App\Domain\Escrow\Enums;

enum PayoutStatus: string
{
    case Pending = 'pending';
    case Processing = 'processing';
    case Paid = 'paid';
    case Failed = 'failed';
}

```

```php
<?php

// app/Domain/Escrow/Jobs/AutoReleaseEscrowJob.php

namespace App\Domain\Escrow\Jobs;

use App\Domain\Disputes\Enums\DisputeStatus;
use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Escrow\Models\EscrowHold;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Orders\Enums\OrderStatus;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class AutoReleaseEscrowJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(public readonly int $escrowHoldId)
    {
    }

    public function handle(EscrowService $escrowService): void
    {
        /** @var EscrowHold|null $hold */
        $hold = EscrowHold::query()->with(['order.dispute'])->find($this->escrowHoldId);
        if (! $hold) {
            return;
        }

        if ($hold->status !== EscrowStatus::Held) {
            return;
        }

        if (! $hold->hold_expires_at || now()->lessThan($hold->hold_expires_at)) {
            return;
        }

        $order = $hold->order;
        if (! $order || $order->status !== OrderStatus::Delivered) {
            return;
        }

        if ($order->dispute && in_array($order->dispute->status, [DisputeStatus::Open, DisputeStatus::UnderReview], true)) {
            return;
        }

        $escrowService->release($hold, null);
    }
}
```

```php
<?php

// app/Domain/Escrow/Models/EscrowHold.php

namespace App\Domain\Escrow\Models;

use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Models\WalletAccount;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EscrowHold extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'status' => EscrowStatus::class,
            'hold_expires_at' => 'datetime',
        ];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function buyerWalletAccount()
    {
        return $this->belongsTo(WalletAccount::class, 'buyer_wallet_account_id');
    }

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_user_id');
    }
}

```

```php
<?php

// app/Domain/Escrow/Models/Payout.php

namespace App\Domain\Escrow\Models;

use App\Domain\Escrow\Enums\PayoutProvider;
use App\Domain\Escrow\Enums\PayoutStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payout extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'status' => PayoutStatus::class,
            'provider' => PayoutProvider::class,
        ];
    }

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_user_id');
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}

```

```php
<?php

// app/Domain/Escrow/Services/EscrowService.php

namespace App\Domain\Escrow\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\Escrow\Enums\EscrowStatus;
use App\Domain\Escrow\Enums\PayoutProvider;
use App\Domain\Escrow\Enums\PayoutStatus;
use App\Domain\Escrow\Models\EscrowHold;
use App\Domain\Escrow\Models\Payout;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Support\Facades\DB;

class EscrowService
{
    public function __construct(
        private readonly WalletService $walletService,
        private readonly AuditLogger $auditLogger,
    ) {}

    public function createHold(Order $order, int $buyerWalletAccountId, int $sellerUserId, float $amount): EscrowHold
    {
        $hold = EscrowHold::firstOrCreate(
            ['order_id' => $order->id],
            [
                'buyer_wallet_account_id' => $buyerWalletAccountId,
                'seller_user_id' => $sellerUserId,
                'amount' => $amount,
                'status' => EscrowStatus::Held,
                'hold_expires_at' => null,
            ],
        );

        if ($hold->wasRecentlyCreated) {
            $this->auditLogger->log(null, 'escrow.hold.created', $hold, [
                'order_id' => $order->id,
                'amount' => $amount,
            ]);
        }

        return $hold;
    }

    public function freeze(EscrowHold $hold): EscrowHold
    {
        if ($hold->status === EscrowStatus::Frozen) {
            return $hold;
        }

        $hold->forceFill(['status' => EscrowStatus::Frozen])->save();
        $this->auditLogger->log(null, 'escrow.frozen', $hold, ['order_id' => $hold->order_id]);

        return $hold->fresh();
    }

    public function release(EscrowHold $hold, ?int $actorUserId = null): EscrowHold
    {
        return DB::transaction(function () use ($hold, $actorUserId) {
            /** @var EscrowHold $locked */
            $locked = EscrowHold::query()->whereKey($hold->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === EscrowStatus::Released) {
                return $locked;
            }

            if ($locked->status !== EscrowStatus::Held) {
                throw new \RuntimeException('Escrow is not releasable.');
            }

            /** @var Order $order */
            $order = Order::query()->whereKey($locked->order_id)->firstOrFail();

            /** @var User $seller */
            $seller = User::query()->whereKey($locked->seller_user_id)->firstOrFail();

            $sellerWallet = $this->walletService->walletFor($seller);

            $this->walletService->record(
                $sellerWallet,
                WalletTransactionType::Release,
                WalletTransactionDirection::In,
                (float) $locked->amount,
                "escrow:order:{$order->id}:release",
                relatedEntityType: 'orders',
                relatedEntityId: $order->id,
                meta: ['actor_user_id' => $actorUserId],
            );

            Payout::firstOrCreate(
                ['order_id' => $order->id],
                [
                    'seller_user_id' => $seller->id,
                    'amount' => $locked->amount,
                    'status' => PayoutStatus::Pending,
                    'provider' => PayoutProvider::Paystack,
                    'provider_ref' => null,
                ],
            );

            $locked->forceFill(['status' => EscrowStatus::Released])->save();
            $this->auditLogger->log($actorUserId, 'escrow.released', $locked, ['order_id' => $locked->order_id]);

            return $locked->fresh();
        });
    }

    public function refund(EscrowHold $hold, ?int $actorUserId = null): EscrowHold
    {
        return DB::transaction(function () use ($hold, $actorUserId) {
            /** @var EscrowHold $locked */
            $locked = EscrowHold::query()->whereKey($hold->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === EscrowStatus::Refunded) {
                return $locked;
            }

            if (! in_array($locked->status, [EscrowStatus::Held, EscrowStatus::Frozen], true)) {
                throw new \RuntimeException('Escrow is not refundable.');
            }

            /** @var Order $order */
            $order = Order::query()->whereKey($locked->order_id)->firstOrFail();

            $buyerWallet = $locked->buyerWalletAccount()->lockForUpdate()->firstOrFail();

            $this->walletService->record(
                $buyerWallet,
                WalletTransactionType::Refund,
                WalletTransactionDirection::In,
                (float) $locked->amount,
                "escrow:order:{$order->id}:refund",
                relatedEntityType: 'orders',
                relatedEntityId: $order->id,
                meta: ['actor_user_id' => $actorUserId],
            );

            $locked->forceFill(['status' => EscrowStatus::Refunded])->save();
            $this->auditLogger->log($actorUserId, 'escrow.refunded', $locked, ['order_id' => $locked->order_id]);

            return $locked->fresh();
        });
    }
}
```

```php
<?php

// app/Domain/Evidence/Enums/EvidenceType.php

namespace App\Domain\Evidence\Enums;

enum EvidenceType: string
{
    case PickupVideo = 'pickup_video';
    case DeliveryPhoto = 'delivery_photo';
}

```

```php
<?php

// app/Domain/Evidence/Models/OrderEvidence.php

namespace App\Domain\Evidence\Models;

use App\Domain\Evidence\Enums\EvidenceType;
use App\Domain\Orders\Models\Order;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderEvidence extends Model
{
    use HasFactory;

    protected $table = 'order_evidence';

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'type' => EvidenceType::class,
        ];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function capturedBy()
    {
        return $this->belongsTo(User::class, 'captured_by_user_id');
    }
}

```

```php
<?php

// app/Domain/Kyc/Controllers/AdminKycController.php

namespace App\Domain\Kyc\Controllers;

use App\Domain\Kyc\Enums\KycStatus;
use App\Domain\Kyc\Enums\KycType;
use App\Domain\Kyc\Models\KycRequest;
use App\Domain\Kyc\Requests\AdminRejectKycRequest;
use App\Domain\Kyc\Resources\KycRequestResource;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Shops\Models\SellerBankAccount;
use App\Domain\Users\Enums\UserStatus;
use Illuminate\Support\Facades\DB;

class AdminKycController
{
    public function approve(KycRequest $kycRequest)
    {
        $admin = request()->user();

        $kyc = DB::transaction(function () use ($kycRequest, $admin) {
            $kycRequest->forceFill([
                'status' => KycStatus::Approved,
                'reviewed_by' => $admin->id,
                'reviewed_at' => now(),
                'rejection_reason' => null,
            ])->save();

            $user = $kycRequest->user()->lockForUpdate()->firstOrFail();
            $user->forceFill(['status' => UserStatus::Active])->save();

            if ($kycRequest->kyc_type === KycType::Seller) {
                SellerBankAccount::query()
                    ->where('seller_user_id', $user->id)
                    ->update(['verified_at' => now()]);

                $user->shop()?->update(['is_verified' => true]);
            }

            if ($kycRequest->kyc_type === KycType::Rider) {
                RiderAvailability::query()
                    ->where('rider_user_id', $user->id)
                    ->update(['status' => 'available', 'last_seen_at' => now()]);
            }

            return $kycRequest->fresh();
        });

        return new KycRequestResource($kyc);
    }

    public function reject(AdminRejectKycRequest $request, KycRequest $kycRequest)
    {
        $admin = $request->user();
        $data = $request->validated();

        $kyc = DB::transaction(function () use ($kycRequest, $admin, $data) {
            $kycRequest->forceFill([
                'status' => KycStatus::Rejected,
                'reviewed_by' => $admin->id,
                'reviewed_at' => now(),
                'rejection_reason' => $data['rejection_reason'],
            ])->save();

            return $kycRequest->fresh();
        });

        return new KycRequestResource($kyc);
    }
}

```

```php
<?php

// app/Domain/Kyc/Controllers/KycController.php

namespace App\Domain\Kyc\Controllers;

use App\Domain\Kyc\Enums\KycType;
use App\Domain\Kyc\Requests\SubmitKycRequest;
use App\Domain\Kyc\Resources\KycRequestResource;
use App\Domain\Kyc\Services\KycService;
use Illuminate\Http\Request;

class KycController
{
    public function __construct(private readonly KycService $kycService)
    {
    }

    public function submit(SubmitKycRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        $type = KycType::from($data['kyc_type']);

        $meta = collect($data)->only([
            'rc_number',
            'bank_name',
            'account_number',
            'account_name',
            'vehicle_type',
            'plate_number',
        ])->filter(fn ($v) => $v !== null)->all();

        try {
            $kyc = $this->kycService->submit(
                $user,
                $type,
                $meta,
                $request->file('documents', []),
                $data['doc_types'] ?? [],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new KycRequestResource($kyc);
    }

    public function status(Request $request)
    {
        $user = $request->user();

        $requests = $user->kycRequests()->latest('id')->get();

        return KycRequestResource::collection($requests);
    }
}

```

```php
<?php

// app/Domain/Kyc/Enums/KycStatus.php

namespace App\Domain\Kyc\Enums;

enum KycStatus: string
{
    case Pending = 'pending';
    case Approved = 'approved';
    case Rejected = 'rejected';
}

```

```php
<?php

// app/Domain/Kyc/Enums/KycType.php

namespace App\Domain\Kyc\Enums;

enum KycType: string
{
    case BuyerBasic = 'buyer_basic';
    case Seller = 'seller';
    case Rider = 'rider';
}

```

```php
<?php

// app/Domain/Kyc/Models/KycDocument.php

namespace App\Domain\Kyc\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KycDocument extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function request()
    {
        return $this->belongsTo(KycRequest::class, 'kyc_request_id');
    }
}

```

```php
<?php

// app/Domain/Kyc/Models/KycRequest.php

namespace App\Domain\Kyc\Models;

use App\Domain\Kyc\Enums\KycStatus;
use App\Domain\Kyc\Enums\KycType;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class KycRequest extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'kyc_type' => KycType::class,
            'status' => KycStatus::class,
            'submitted_at' => 'datetime',
            'reviewed_at' => 'datetime',
            'meta_json' => 'array',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function documents()
    {
        return $this->hasMany(KycDocument::class);
    }

    public function reviewer()
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }
}
```

```php
<?php

// app/Domain/Kyc/Requests/AdminRejectKycRequest.php

namespace App\Domain\Kyc\Requests;

use Illuminate\Foundation\Http\FormRequest;

class AdminRejectKycRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'rejection_reason' => ['required', 'string', 'max:2000'],
        ];
    }
}

```

```php
<?php

// app/Domain/Kyc/Requests/SubmitKycRequest.php

namespace App\Domain\Kyc\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SubmitKycRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'kyc_type' => ['required', 'string', Rule::in(['buyer_basic', 'seller', 'rider'])],

            'rc_number' => ['required_if:kyc_type,seller', 'string', 'max:64'],
            'bank_name' => ['required_if:kyc_type,seller', 'string', 'max:128'],
            'account_number' => ['required_if:kyc_type,seller', 'string', 'max:32'],
            'account_name' => ['required_if:kyc_type,seller', 'string', 'max:128'],

            'vehicle_type' => ['required_if:kyc_type,rider', 'string', Rule::in(['bike', 'car', 'tricycle'])],
            'plate_number' => ['nullable', 'string', 'max:32'],

            'documents' => ['nullable', 'array', 'max:10'],
            'documents.*' => ['file', 'max:10240'],
            'doc_types' => ['nullable', 'array'],
            'doc_types.*' => ['string', 'max:64'],
        ];
    }
}

```

```php
<?php

// app/Domain/Kyc/Resources/KycRequestResource.php

namespace App\Domain\Kyc\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class KycRequestResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Kyc\Models\KycRequest $kyc */
        $kyc = $this->resource;

        return [
            'id' => $kyc->id,
            'user_id' => $kyc->user_id,
            'kyc_type' => $kyc->kyc_type->value,
            'status' => $kyc->status->value,
            'submitted_at' => optional($kyc->submitted_at)?->toISOString(),
            'reviewed_by' => $kyc->reviewed_by,
            'reviewed_at' => optional($kyc->reviewed_at)?->toISOString(),
            'rejection_reason' => $kyc->rejection_reason,
            'meta' => $kyc->meta_json,
        ];
    }
}

```

```php
<?php

// app/Domain/Kyc/Services/KycService.php

namespace App\Domain\Kyc\Services;

use App\Domain\Kyc\Enums\KycStatus;
use App\Domain\Kyc\Enums\KycType;
use App\Domain\Kyc\Models\KycDocument;
use App\Domain\Kyc\Models\KycRequest;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Riders\Models\RiderProfile;
use App\Domain\Shops\Models\SellerBankAccount;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class KycService
{
    /**
     * @param  list<UploadedFile>  $documents
     * @param  list<string>  $docTypes
     */
    public function submit(User $user, KycType $type, array $meta, array $documents = [], array $docTypes = []): KycRequest
    {
        return DB::transaction(function () use ($user, $type, $meta, $documents, $docTypes) {
            if (in_array($type, [KycType::Seller, KycType::Rider], true)) {
                $operationalZoneId = UserZone::query()
                    ->where('user_id', $user->id)
                    ->where('type', 'operational')
                    ->value('zone_id');

                if (! $operationalZoneId) {
                    throw new \RuntimeException('Operational zone is required.');
                }
            }

            $kyc = KycRequest::create([
                'user_id' => $user->id,
                'kyc_type' => $type,
                'status' => KycStatus::Pending,
                'submitted_at' => now(),
                'reviewed_by' => null,
                'reviewed_at' => null,
                'rejection_reason' => null,
                'meta_json' => $meta === [] ? null : $meta,
            ]);

            if ($type === KycType::Seller) {
                SellerBankAccount::updateOrCreate(
                    ['seller_user_id' => $user->id],
                    [
                        'bank_name' => (string) ($meta['bank_name'] ?? ''),
                        'account_number' => (string) ($meta['account_number'] ?? ''),
                        'account_name' => (string) ($meta['account_name'] ?? ''),
                        'verified_at' => null,
                    ],
                );
            }

            if ($type === KycType::Rider) {
                $profile = RiderProfile::query()->where('rider_user_id', $user->id)->first();
                if (! $profile) {
                    $profile = new RiderProfile(['rider_user_id' => $user->id, 'qr_code_token' => Str::uuid()->toString()]);
                }

                $profile->forceFill([
                    'vehicle_type' => (string) ($meta['vehicle_type'] ?? 'bike'),
                    'plate_number' => $meta['plate_number'] ?? null,
                ])->save();

                RiderAvailability::firstOrCreate(
                    ['rider_user_id' => $user->id],
                    ['status' => 'offline', 'last_seen_at' => now()],
                );
            }

            $disk = (string) config('smartlink.media_disk', 'local');
            foreach ($documents as $i => $file) {
                $path = Storage::disk($disk)->putFileAs(
                    "kyc/{$user->id}/{$kyc->id}",
                    $file,
                    Str::uuid()->toString().'.'.$file->getClientOriginalExtension(),
                );

                KycDocument::create([
                    'kyc_request_id' => $kyc->id,
                    'doc_type' => $docTypes[$i] ?? 'document',
                    'file_url' => Storage::disk($disk)->url($path),
                ]);
            }

            // Keep sellers/riders pending until admin approval.
            if ($user->status !== UserStatus::Pending) {
                $user->forceFill(['status' => UserStatus::Pending])->save();
            }

            return $kyc->fresh(['documents']);
        });
    }
}
```

```php
<?php

// app/Domain/Notifications/Contracts/OtpProvider.php

namespace App\Domain\Notifications\Contracts;

interface OtpProvider
{
    public function send(string $phone, string $message): void;
}

```

```php
<?php

// app/Domain/Notifications/Jobs/SendOtpJob.php

namespace App\Domain\Notifications\Jobs;

use App\Domain\Notifications\Services\NotificationService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendOtpJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(
        public readonly string $phone,
        public readonly string $code,
        public readonly int $ttlMinutes = 5,
    ) {
    }

    public function handle(NotificationService $notificationService): void
    {
        $notificationService->sendOtp($this->phone, $this->code, $this->ttlMinutes);
    }
}

```

```php
<?php

// app/Domain/Notifications/Providers/LogOtpProvider.php

namespace App\Domain\Notifications\Providers;

use App\Domain\Notifications\Contracts\OtpProvider;
use Illuminate\Support\Facades\Log;

class LogOtpProvider implements OtpProvider
{
    public function send(string $phone, string $message): void
    {
        Log::info('OTP (log driver)', [
            'phone' => $phone,
            'message' => $message,
        ]);
    }
}

```

```php
<?php

// app/Domain/Notifications/Providers/SendchampOtpProvider.php

namespace App\Domain\Notifications\Providers;

use App\Domain\Notifications\Contracts\OtpProvider;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;

class SendchampOtpProvider implements OtpProvider
{
    /**
     * @throws RequestException
     */
    public function send(string $phone, string $message): void
    {
        $apiKey = config('smartlink.otp.sendchamp.api_key');
        $senderId = config('smartlink.otp.sender_id', 'Smartlink');

        if (! $apiKey) {
            throw new \RuntimeException('SENDCHAMP_API_KEY is not configured.');
        }

        $baseUrl = rtrim((string) config('smartlink.otp.sendchamp.base_url'), '/');

        Http::baseUrl($baseUrl)
            ->withToken($apiKey)
            ->asJson()
            ->post('/sms/send', [
                'to' => $phone,
                'message' => $message,
                'sender_name' => $senderId,
                'route' => 'sms',
            ])
            ->throw();
    }
}

```

```php
<?php

// app/Domain/Notifications/Providers/TermiiOtpProvider.php

namespace App\Domain\Notifications\Providers;

use App\Domain\Notifications\Contracts\OtpProvider;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;

class TermiiOtpProvider implements OtpProvider
{
    /**
     * @throws RequestException
     */
    public function send(string $phone, string $message): void
    {
        $apiKey = config('smartlink.otp.termii.api_key');
        $senderId = config('smartlink.otp.sender_id', 'Smartlink');

        if (! $apiKey) {
            throw new \RuntimeException('TERMII_API_KEY is not configured.');
        }

        $baseUrl = rtrim((string) config('smartlink.otp.termii.base_url'), '/');

        Http::baseUrl($baseUrl)
            ->asJson()
            ->post('/api/sms/send', [
                'to' => $phone,
                'from' => $senderId,
                'sms' => $message,
                'type' => 'plain',
                'channel' => 'generic',
                'api_key' => $apiKey,
            ])
            ->throw();
    }
}

```

```php
<?php

// app/Domain/Notifications/Services/NotificationService.php

namespace App\Domain\Notifications\Services;

use App\Domain\Notifications\Contracts\OtpProvider;
use Illuminate\Support\Facades\Log;

class NotificationService
{
    public function __construct(private readonly OtpProvider $otpProvider)
    {
    }

    public function sendOtp(string $phone, string $code, int $ttlMinutes = 5): void
    {
        $message = "Your Smartlink OTP is {$code}. Expires in {$ttlMinutes} minutes.";

        $this->otpProvider->send($phone, $message);
    }

    public function pushPlaceholder(int $userId, string $title, array $data = []): void
    {
        Log::info('Push notification placeholder', [
            'user_id' => $userId,
            'title' => $title,
            'data' => $data,
        ]);
    }
}

```

```php
<?php

// app/Domain/Orders/Controllers/OrderController.php

namespace App\Domain\Orders\Controllers;

use App\Domain\Disputes\Resources\DisputeResource;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Requests\RaiseDisputeRequest;
use App\Domain\Orders\Requests\StoreOrderRequest;
use App\Domain\Orders\Resources\OrderResource;
use App\Domain\Orders\Services\OrderService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;

class OrderController
{
    public function __construct(private readonly OrderService $orderService)
    {
    }

    public function store(StoreOrderRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        $order = $this->orderService->placeOrder(
            $user,
            (int) $data['shop_id'],
            (string) $data['delivery_address_text'],
            $data['items'],
        );

        return new OrderResource($order->load(['items', 'escrowHold']));
    }

    public function index(Request $request)
    {
        $user = $request->user();

        $orders = Order::query()
            ->when($user->role->value === 'buyer', fn ($q) => $q->where('buyer_user_id', $user->id))
            ->when($user->role->value === 'seller', function ($q) use ($user) {
                $shopId = $user->shop?->id;
                $q->where('shop_id', $shopId ?? 0);
            })
            ->when($user->role->value === 'rider', function ($q) use ($user) {
                $q->whereHas('dispatchJob', fn ($dq) => $dq->where('assigned_rider_user_id', $user->id));
            })
            ->latest('id')
            ->paginate(20);

        return OrderResource::collection($orders);
    }

    public function show(Request $request, Order $order)
    {
        Gate::authorize('view', $order);

        return new OrderResource($order->load(['items', 'escrowHold', 'dispatchJob']));
    }

    public function confirmDelivery(Request $request, Order $order)
    {
        Gate::authorize('confirmDelivery', $order);

        try {
            $updated = $this->orderService->confirmDelivery($request->user(), $order);
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new OrderResource($updated->load(['items', 'escrowHold']));
    }

    public function raiseDispute(RaiseDisputeRequest $request, Order $order)
    {
        Gate::authorize('raiseDispute', $order);

        try {
            $dispute = $this->orderService->raiseDispute($request->user(), $order, $request->validated());
        } catch (\RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return new DisputeResource($dispute);
    }
}
```

```php
<?php

// app/Domain/Orders/Enums/OrderPaymentStatus.php

namespace App\Domain\Orders\Enums;

enum OrderPaymentStatus: string
{
    case Pending = 'pending';
    case Paid = 'paid';
    case Refunded = 'refunded';
}

```

```php
<?php

// app/Domain/Orders/Enums/OrderStatus.php

namespace App\Domain\Orders\Enums;

enum OrderStatus: string
{
    case Placed = 'placed';
    case Paid = 'paid';
    case AcceptedBySeller = 'accepted_by_seller';
    case Dispatching = 'dispatching';
    case AssignedToRider = 'assigned_to_rider';
    case PickedUp = 'picked_up';
    case Delivered = 'delivered';
    case Confirmed = 'confirmed';
    case Cancelled = 'cancelled';
    case Disputed = 'disputed';
}

```

```php
<?php

// app/Domain/Orders/Models/Order.php

namespace App\Domain\Orders\Models;

use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Disputes\Models\Dispute;
use App\Domain\Escrow\Models\EscrowHold;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Products\Models\Product;
use App\Domain\Ratings\Models\Rating;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'subtotal_amount' => 'decimal:2',
            'delivery_fee_amount' => 'decimal:2',
            'total_amount' => 'decimal:2',
            'status' => OrderStatus::class,
            'payment_status' => OrderPaymentStatus::class,
        ];
    }

    public function buyer()
    {
        return $this->belongsTo(User::class, 'buyer_user_id');
    }

    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function statusHistory()
    {
        return $this->hasMany(OrderStatusHistory::class);
    }

    public function escrowHold()
    {
        return $this->hasOne(EscrowHold::class);
    }

    public function dispatchJob()
    {
        return $this->hasOne(DispatchJob::class);
    }

    public function dispute()
    {
        return $this->hasOne(Dispute::class);
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }
}

```

```php
<?php

// app/Domain/Orders/Models/OrderItem.php

namespace App\Domain\Orders\Models;

use App\Domain\Products\Models\Product;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'unit_price' => 'decimal:2',
            'line_total' => 'decimal:2',
        ];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}

```

```php
<?php

// app/Domain/Orders/Models/OrderStatusHistory.php

namespace App\Domain\Orders\Models;

use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderStatusHistory extends Model
{
    use HasFactory;

    protected $table = 'order_status_history';

    protected $guarded = [];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function changedBy()
    {
        return $this->belongsTo(User::class, 'changed_by_user_id');
    }
}

```

```php
<?php

// app/Domain/Orders/Policies/OrderPolicy.php

namespace App\Domain\Orders\Policies;

use App\Domain\Orders\Models\Order;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Models\User;

class OrderPolicy
{
    public function view(User $user, Order $order): bool
    {
        if ($user->role === UserRole::Admin) {
            return true;
        }

        if ($user->role === UserRole::Buyer) {
            return (int) $order->buyer_user_id === (int) $user->id;
        }

        if ($user->role === UserRole::Seller) {
            return (int) $order->shop_id === (int) ($user->shop?->id ?? 0);
        }

        if ($user->role === UserRole::Rider) {
            return (int) ($order->dispatchJob?->assigned_rider_user_id ?? 0) === (int) $user->id;
        }

        return false;
    }

    public function dispatch(User $user, Order $order): bool
    {
        return $user->role === UserRole::Seller
            && (int) $order->shop_id === (int) ($user->shop?->id ?? 0);
    }

    public function confirmDelivery(User $user, Order $order): bool
    {
        return $user->role === UserRole::Buyer
            && (int) $order->buyer_user_id === (int) $user->id;
    }

    public function raiseDispute(User $user, Order $order): bool
    {
        return $this->confirmDelivery($user, $order);
    }
}

```

```php
<?php

// app/Domain/Orders/Requests/RaiseDisputeRequest.php

namespace App\Domain\Orders\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class RaiseDisputeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'reason' => ['required', 'string', Rule::in(['wrong_item', 'damaged_item', 'not_delivered', 'other'])],
            'description' => ['nullable', 'string', 'max:2000'],
        ];
    }
}

```

```php
<?php

// app/Domain/Orders/Requests/StoreOrderRequest.php

namespace App\Domain\Orders\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'shop_id' => ['required', 'integer', 'exists:shops,id'],
            'delivery_address_text' => ['required', 'string', 'max:255'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['required', 'integer', 'exists:products,id'],
            'items.*.qty' => ['required', 'integer', 'min:1'],
        ];
    }
}

```

```php
<?php

// app/Domain/Orders/Resources/OrderItemResource.php

namespace App\Domain\Orders\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderItemResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Orders\Models\OrderItem $item */
        $item = $this->resource;

        return [
            'id' => $item->id,
            'product_id' => $item->product_id,
            'qty' => $item->qty,
            'unit_price' => (string) $item->unit_price,
            'line_total' => (string) $item->line_total,
        ];
    }
}

```

```php
<?php

// app/Domain/Orders/Resources/OrderResource.php

namespace App\Domain\Orders\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Orders\Models\Order $order */
        $order = $this->resource;

        return [
            'id' => $order->id,
            'buyer_user_id' => $order->buyer_user_id,
            'shop_id' => $order->shop_id,
            'zone_id' => $order->zone_id,
            'subtotal_amount' => (string) $order->subtotal_amount,
            'delivery_fee_amount' => (string) $order->delivery_fee_amount,
            'total_amount' => (string) $order->total_amount,
            'status' => $order->status->value,
            'payment_status' => $order->payment_status->value,
            'delivery_address_text' => $order->delivery_address_text,
            'escrow' => $order->relationLoaded('escrowHold') && $order->escrowHold
                ? [
                    'status' => $order->escrowHold->status->value,
                    'hold_expires_at' => optional($order->escrowHold->hold_expires_at)?->toISOString(),
                ]
                : null,
            'items' => OrderItemResource::collection($this->whenLoaded('items')),
            'created_at' => optional($order->created_at)?->toISOString(),
        ];
    }
}
```

```php
<?php

// app/Domain/Orders/Services/OrderService.php

namespace App\Domain\Orders\Services;

use App\Domain\Disputes\Enums\DisputeStatus;
use App\Domain\Disputes\Models\Dispute;
use App\Domain\Escrow\Services\EscrowService;
use App\Domain\Orders\Enums\OrderPaymentStatus;
use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Models\OrderItem;
use App\Domain\Orders\Models\OrderStatusHistory;
use App\Domain\Products\Enums\ProductStatus;
use App\Domain\Products\Models\Product;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Support\Facades\DB;

class OrderService
{
    public function __construct(
        private readonly WalletService $walletService,
        private readonly EscrowService $escrowService,
    ) {
    }

    /**
     * @param  list<array{product_id:int, qty:int}>  $items
     */
    public function placeOrder(User $buyer, int $shopId, string $deliveryAddressText, array $items): Order
    {
        $this->walletService->requireVerifiedForWallet($buyer);

        return DB::transaction(function () use ($buyer, $shopId, $deliveryAddressText, $items): Order {
            /** @var Shop $shop */
            $shop = Shop::query()->whereKey($shopId)->firstOrFail();

            $buyerHomeZoneId = UserZone::query()
                ->where('user_id', $buyer->id)
                ->where('type', 'home')
                ->value('zone_id');

            if (! $buyerHomeZoneId) {
                throw new \RuntimeException('Home zone is required before placing orders.');
            }

            if ((int) $buyerHomeZoneId !== (int) $shop->zone_id) {
                throw new \RuntimeException('Order zone mismatch. This shop is outside your home zone.');
            }

            $order = Order::create([
                'buyer_user_id' => $buyer->id,
                'shop_id' => $shop->id,
                'zone_id' => $shop->zone_id,
                'subtotal_amount' => 0,
                'delivery_fee_amount' => 0,
                'total_amount' => 0,
                'status' => OrderStatus::Placed,
                'payment_status' => OrderPaymentStatus::Pending,
                'delivery_address_text' => $deliveryAddressText,
            ]);

            $this->appendHistory($order, OrderStatus::Placed, $buyer->id);

            $subtotal = 0.0;

            foreach ($items as $item) {
                $productId = (int) $item['product_id'];
                $qty = (int) $item['qty'];

                if ($qty <= 0) {
                    throw new \InvalidArgumentException('Invalid quantity.');
                }

                /** @var Product $product */
                $product = Product::query()->whereKey($productId)->lockForUpdate()->firstOrFail();

                if ((int) $product->shop_id !== (int) $shop->id) {
                    throw new \RuntimeException('Product does not belong to the selected shop.');
                }

                if ($product->status !== ProductStatus::Active) {
                    throw new \RuntimeException('Product is not available.');
                }

                if ($product->stock_qty < $qty) {
                    throw new \RuntimeException('Insufficient stock for product: '.$product->name);
                }

                $lineTotal = (float) $product->price * $qty;
                $subtotal += $lineTotal;

                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $product->id,
                    'qty' => $qty,
                    'unit_price' => $product->price,
                    'line_total' => $lineTotal,
                ]);

                $product->forceFill(['stock_qty' => $product->stock_qty - $qty])->save();
                if ($product->stock_qty <= 0) {
                    $product->forceFill(['status' => ProductStatus::OutOfStock])->save();
                }
            }

            $deliveryFee = 0.0;
            $total = $subtotal + $deliveryFee;

            $order->forceFill([
                'subtotal_amount' => $subtotal,
                'delivery_fee_amount' => $deliveryFee,
                'total_amount' => $total,
            ])->save();

            $buyerWallet = $this->walletService->walletFor($buyer);

            $this->walletService->record(
                $buyerWallet,
                WalletTransactionType::Hold,
                WalletTransactionDirection::Out,
                $total,
                "order:{$order->id}:hold",
                relatedEntityType: 'orders',
                relatedEntityId: $order->id,
                meta: ['actor_user_id' => $buyer->id],
            );

            $this->escrowService->createHold(
                $order,
                $buyerWallet->id,
                (int) $shop->seller_user_id,
                $total,
            );

            $order->forceFill([
                'status' => OrderStatus::Paid,
                'payment_status' => OrderPaymentStatus::Paid,
            ])->save();

            $this->appendHistory($order, OrderStatus::Paid, $buyer->id);

            return $order->fresh(['items', 'shop', 'zone', 'escrowHold']);
        });
    }

    public function confirmDelivery(User $buyer, Order $order): Order
    {
        if ((int) $order->buyer_user_id !== (int) $buyer->id) {
            throw new \RuntimeException('Forbidden.');
        }

        return DB::transaction(function () use ($buyer, $order): Order {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === OrderStatus::Confirmed) {
                return $locked->fresh(['escrowHold', 'dispatchJob']);
            }

            if ($locked->status !== OrderStatus::Delivered) {
                throw new \RuntimeException('Order is not delivered.');
            }

            $locked->forceFill(['status' => OrderStatus::Confirmed])->save();
            $this->appendHistory($locked, OrderStatus::Confirmed, $buyer->id);

            $hold = $locked->escrowHold()->firstOrFail();
            $this->escrowService->release($hold, $buyer->id);

            return $locked->fresh(['escrowHold', 'dispatchJob']);
        });
    }

    /**
     * @param  array{reason:string, description?:string|null}  $payload
     */
    public function raiseDispute(User $buyer, Order $order, array $payload): Dispute
    {
        if ((int) $order->buyer_user_id !== (int) $buyer->id) {
            throw new \RuntimeException('Forbidden.');
        }

        return DB::transaction(function () use ($buyer, $order, $payload): Dispute {
            /** @var Order $locked */
            $locked = Order::query()->whereKey($order->id)->lockForUpdate()->firstOrFail();

            $existing = Dispute::query()->where('order_id', $locked->id)->first();
            if ($existing) {
                return $existing;
            }

            if ($locked->status !== OrderStatus::Delivered) {
                throw new \RuntimeException('Disputes can only be raised after delivery.');
            }

            $hold = $locked->escrowHold()->lockForUpdate()->firstOrFail();
            if ($hold->hold_expires_at && now()->greaterThan($hold->hold_expires_at)) {
                throw new \RuntimeException('Dispute window has expired.');
            }

            $dispute = Dispute::create([
                'order_id' => $locked->id,
                'raised_by_user_id' => $buyer->id,
                'reason' => $payload['reason'],
                'description' => $payload['description'] ?? null,
                'status' => DisputeStatus::Open,
            ]);

            $locked->forceFill(['status' => OrderStatus::Disputed])->save();
            $this->appendHistory($locked, OrderStatus::Disputed, $buyer->id);

            $this->escrowService->freeze($hold);

            return $dispute;
        });
    }

    private function appendHistory(Order $order, OrderStatus $status, ?int $changedByUserId): void
    {
        OrderStatusHistory::create([
            'order_id' => $order->id,
            'status' => $status->value,
            'changed_by_user_id' => $changedByUserId,
        ]);
    }
}
```

```php
<?php

// app/Domain/Payments/Services/PaystackService.php

namespace App\Domain\Payments\Services;

use App\Domain\Users\Models\User;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;

class PaystackService
{
    /**
     * @return array{authorization_url: string, reference: string}
     */
    public function initializeTopup(User $user, float $amount): array
    {
        $secretKey = config('smartlink.paystack.secret_key');
        $baseUrl = rtrim((string) config('smartlink.paystack.base_url', 'https://api.paystack.co'), '/');

        if (! $secretKey) {
            throw new \RuntimeException('PAYSTACK_SECRET_KEY is not configured.');
        }

        if (! $user->email) {
            throw new \RuntimeException('Email is required to initialize Paystack payments.');
        }

        $reference = (string) Str::uuid();
        $amountKobo = (int) round($amount * 100);

        $response = Http::baseUrl($baseUrl)
            ->withToken($secretKey)
            ->asJson()
            ->post('/transaction/initialize', [
                'email' => $user->email,
                'amount' => $amountKobo,
                'reference' => $reference,
                'metadata' => [
                    'user_id' => $user->id,
                    'purpose' => 'wallet_topup',
                ],
            ])
            ->throw()
            ->json();

        $authUrl = (string) data_get($response, 'data.authorization_url');
        $ref = (string) data_get($response, 'data.reference', $reference);

        if ($authUrl === '' || $ref === '') {
            throw new \RuntimeException('Paystack initialize response is missing authorization_url/reference.');
        }

        return [
            'authorization_url' => $authUrl,
            'reference' => $ref,
        ];
    }
}

```

```php
<?php

// app/Domain/Products/Controllers/PublicProductController.php

namespace App\Domain\Products\Controllers;

use App\Domain\Products\Models\Product;
use App\Domain\Products\Resources\ProductResource;
use Illuminate\Http\Request;

class PublicProductController
{
    public function index(Request $request)
    {
        $zoneId = $request->query('zone_id');
        $shopId = $request->query('shop_id');

        $products = Product::query()
            ->with('images')
            ->where('status', 'active')
            ->whereHas('shop', function ($q) use ($zoneId, $shopId) {
                $q->where('is_verified', true)
                    ->when($zoneId, fn ($qq) => $qq->where('zone_id', $zoneId))
                    ->when($shopId, fn ($qq) => $qq->where('id', $shopId));
            })
            ->latest('id')
            ->paginate(20);

        return ProductResource::collection($products);
    }

    public function show(Product $product)
    {
        if (! $product->shop()->where('is_verified', true)->exists()) {
            return response()->json(['message' => 'Not found.'], 404);
        }

        return new ProductResource($product->load('images'));
    }
}

```

```php
<?php

// app/Domain/Products/Controllers/SellerProductController.php

namespace App\Domain\Products\Controllers;

use App\Domain\Products\Models\Product;
use App\Domain\Products\Models\ProductImage;
use App\Domain\Products\Requests\CreateProductRequest;
use App\Domain\Products\Requests\UpdateProductRequest;
use App\Domain\Products\Resources\ProductResource;
use App\Domain\Shops\Models\Shop;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class SellerProductController
{
    public function store(CreateProductRequest $request)
    {
        $seller = $request->user();
        $data = $request->validated();

        /** @var Shop|null $shop */
        $shop = Shop::query()->where('seller_user_id', $seller->id)->first();
        if (! $shop) {
            return response()->json(['message' => 'Create a shop first.'], 422);
        }

        $disk = (string) config('smartlink.media_disk', 'local');

        $product = DB::transaction(function () use ($shop, $data, $request, $disk) {
            $product = Product::create([
                'shop_id' => $shop->id,
                'name' => $data['name'],
                'description' => $data['description'] ?? null,
                'price' => $data['price'],
                'currency' => (string) config('smartlink.currency', 'NGN'),
                'stock_qty' => $data['stock_qty'],
                'status' => $data['status'] ?? 'active',
            ]);

            $files = $request->file('images', []);
            foreach ($files as $i => $file) {
                $path = Storage::disk($disk)->putFileAs(
                    "products/{$product->id}",
                    $file,
                    Str::uuid()->toString().'.'.$file->getClientOriginalExtension(),
                );

                ProductImage::create([
                    'product_id' => $product->id,
                    'image_url' => Storage::disk($disk)->url($path),
                    'sort_order' => $i,
                ]);
            }

            return $product;
        });

        return new ProductResource($product->load('images'));
    }

    public function update(UpdateProductRequest $request, Product $product)
    {
        Gate::authorize('update', $product);

        $data = $request->validated();
        $disk = (string) config('smartlink.media_disk', 'local');

        DB::transaction(function () use ($product, $data, $request, $disk) {
            $product->fill(collect($data)->except(['images'])->all());
            $product->save();

            if ($request->hasFile('images')) {
                $product->images()->delete();

                $files = $request->file('images', []);
                foreach ($files as $i => $file) {
                    $path = Storage::disk($disk)->putFileAs(
                        "products/{$product->id}",
                        $file,
                        Str::uuid()->toString().'.'.$file->getClientOriginalExtension(),
                    );

                    ProductImage::create([
                        'product_id' => $product->id,
                        'image_url' => Storage::disk($disk)->url($path),
                        'sort_order' => $i,
                    ]);
                }
            }
        });

        return new ProductResource($product->fresh()->load('images'));
    }
}
```

```php
<?php

// app/Domain/Products/Enums/ProductStatus.php

namespace App\Domain\Products\Enums;

enum ProductStatus: string
{
    case Active = 'active';
    case Inactive = 'inactive';
    case OutOfStock = 'out_of_stock';
}

```

```php
<?php

// app/Domain/Products/Models/Product.php

namespace App\Domain\Products\Models;

use App\Domain\Orders\Models\OrderItem;
use App\Domain\Products\Enums\ProductStatus;
use App\Domain\Shops\Models\Shop;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'status' => ProductStatus::class,
        ];
    }

    public function shop()
    {
        return $this->belongsTo(Shop::class);
    }

    public function images()
    {
        return $this->hasMany(ProductImage::class);
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}

```

```php
<?php

// app/Domain/Products/Models/ProductImage.php

namespace App\Domain\Products\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ProductImage extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}

```

```php
<?php

// app/Domain/Products/Policies/ProductPolicy.php

namespace App\Domain\Products\Policies;

use App\Domain\Products\Models\Product;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Models\User;

class ProductPolicy
{
    public function update(User $user, Product $product): bool
    {
        return $user->role === UserRole::Seller
            && (int) $product->shop_id === (int) ($user->shop?->id ?? 0);
    }
}

```

```php
<?php

// app/Domain/Products/Requests/CreateProductRequest.php

namespace App\Domain\Products\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class CreateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:5000'],
            'price' => ['required', 'numeric', 'min:0.01'],
            'stock_qty' => ['required', 'integer', 'min:0'],
            'status' => ['nullable', 'string', Rule::in(['active', 'inactive', 'out_of_stock'])],
            'images' => ['nullable', 'array', 'max:5'],
            'images.*' => ['file', 'image', 'max:4096'],
        ];
    }
}

```

```php
<?php

// app/Domain/Products/Requests/UpdateProductRequest.php

namespace App\Domain\Products\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'string', 'max:255'],
            'description' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'price' => ['sometimes', 'numeric', 'min:0.01'],
            'stock_qty' => ['sometimes', 'integer', 'min:0'],
            'status' => ['sometimes', 'string', Rule::in(['active', 'inactive', 'out_of_stock'])],
            'images' => ['sometimes', 'array', 'max:5'],
            'images.*' => ['file', 'image', 'max:4096'],
        ];
    }
}

```

```php
<?php

// app/Domain/Products/Resources/ProductResource.php

namespace App\Domain\Products\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Products\Models\Product $product */
        $product = $this->resource;

        return [
            'id' => $product->id,
            'shop_id' => $product->shop_id,
            'name' => $product->name,
            'description' => $product->description,
            'price' => (string) $product->price,
            'currency' => $product->currency,
            'stock_qty' => $product->stock_qty,
            'status' => $product->status->value,
            'images' => $product->relationLoaded('images')
                ? $product->images->sortBy('sort_order')->pluck('image_url')->values()->all()
                : [],
            'created_at' => optional($product->created_at)?->toISOString(),
        ];
    }
}

```

```php
<?php

// app/Domain/Ratings/Controllers/RatingController.php

namespace App\Domain\Ratings\Controllers;

use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Ratings\Models\Rating;
use App\Domain\Ratings\Requests\StoreRatingRequest;
use App\Domain\Ratings\Resources\RatingResource;
use Illuminate\Support\Facades\DB;

class RatingController
{
    public function store(StoreRatingRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        /** @var Order $order */
        $order = Order::query()->with(['shop', 'dispatchJob'])->whereKey($data['order_id'])->firstOrFail();

        if ((int) $order->buyer_user_id !== (int) $user->id) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        if ($order->status !== OrderStatus::Confirmed) {
            return response()->json(['message' => 'Ratings are allowed after confirmation.'], 422);
        }

        $rateeUserId = null;
        if ($data['ratee_type'] === 'seller') {
            $rateeUserId = (int) $order->shop->seller_user_id;
        } else {
            $rateeUserId = (int) ($order->dispatchJob?->assigned_rider_user_id ?? 0);
            if (! $rateeUserId) {
                return response()->json(['message' => 'No rider assigned to this order.'], 422);
            }
        }

        $rating = DB::transaction(function () use ($data, $user, $order, $rateeUserId) {
            $existing = Rating::query()
                ->where('order_id', $order->id)
                ->where('rater_user_id', $user->id)
                ->where('ratee_type', $data['ratee_type'])
                ->first();

            if ($existing) {
                return $existing;
            }

            return Rating::create([
                'order_id' => $order->id,
                'rater_user_id' => $user->id,
                'ratee_user_id' => $rateeUserId,
                'ratee_type' => $data['ratee_type'],
                'stars' => $data['stars'],
                'comment' => $data['comment'] ?? null,
            ]);
        });

        return new RatingResource($rating);
    }
}

```

```php
<?php

// app/Domain/Ratings/Enums/RateeType.php

namespace App\Domain\Ratings\Enums;

enum RateeType: string
{
    case Seller = 'seller';
    case Rider = 'rider';
}

```

```php
<?php

// app/Domain/Ratings/Models/Rating.php

namespace App\Domain\Ratings\Models;

use App\Domain\Orders\Models\Order;
use App\Domain\Ratings\Enums\RateeType;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'ratee_type' => RateeType::class,
        ];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function rater()
    {
        return $this->belongsTo(User::class, 'rater_user_id');
    }

    public function ratee()
    {
        return $this->belongsTo(User::class, 'ratee_user_id');
    }
}

```

```php
<?php

// app/Domain/Ratings/Requests/StoreRatingRequest.php

namespace App\Domain\Ratings\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreRatingRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'order_id' => ['required', 'integer', 'exists:orders,id'],
            'ratee_type' => ['required', 'string', Rule::in(['seller', 'rider'])],
            'stars' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string', 'max:2000'],
        ];
    }
}

```

```php
<?php

// app/Domain/Ratings/Resources/RatingResource.php

namespace App\Domain\Ratings\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RatingResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Ratings\Models\Rating $rating */
        $rating = $this->resource;

        return [
            'id' => $rating->id,
            'order_id' => $rating->order_id,
            'rater_user_id' => $rating->rater_user_id,
            'ratee_user_id' => $rating->ratee_user_id,
            'ratee_type' => $rating->ratee_type->value,
            'stars' => $rating->stars,
            'comment' => $rating->comment,
            'created_at' => optional($rating->created_at)?->toISOString(),
        ];
    }
}

```

```php
<?php

// app/Domain/Riders/Enums/RiderAvailabilityStatus.php

namespace App\Domain\Riders\Enums;

enum RiderAvailabilityStatus: string
{
    case Offline = 'offline';
    case Available = 'available';
    case Busy = 'busy';
}

```

```php
<?php

// app/Domain/Riders/Enums/VehicleType.php

namespace App\Domain\Riders\Enums;

enum VehicleType: string
{
    case Bike = 'bike';
    case Car = 'car';
    case Tricycle = 'tricycle';
}

```

```php
<?php

// app/Domain/Riders/Models/RiderAvailability.php

namespace App\Domain\Riders\Models;

use App\Domain\Riders\Enums\RiderAvailabilityStatus;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RiderAvailability extends Model
{
    use HasFactory;

    protected $table = 'rider_availability';

    protected $primaryKey = 'rider_user_id';
    public $incrementing = false;

    public $timestamps = false;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'status' => RiderAvailabilityStatus::class,
            'last_seen_at' => 'datetime',
        ];
    }

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_user_id');
    }
}

```

```php
<?php

// app/Domain/Riders/Models/RiderProfile.php

namespace App\Domain\Riders\Models;

use App\Domain\Riders\Enums\VehicleType;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RiderProfile extends Model
{
    use HasFactory;

    protected $primaryKey = 'rider_user_id';
    public $incrementing = false;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'vehicle_type' => VehicleType::class,
            'is_elite' => 'boolean',
        ];
    }

    public function rider()
    {
        return $this->belongsTo(User::class, 'rider_user_id');
    }
}

```

```php
<?php

// app/Domain/Shops/Controllers/PublicShopController.php

namespace App\Domain\Shops\Controllers;

use App\Domain\Shops\Models\Shop;
use App\Domain\Shops\Resources\ShopResource;
use Illuminate\Http\Request;

class PublicShopController
{
    public function index(Request $request)
    {
        $zoneId = $request->query('zone_id');

        $shops = Shop::query()
            ->where('is_verified', true)
            ->when($zoneId, fn ($q) => $q->where('zone_id', $zoneId))
            ->latest('id')
            ->paginate(20);

        return ShopResource::collection($shops);
    }

    public function show(Shop $shop)
    {
        if (! $shop->is_verified) {
            return response()->json(['message' => 'Not found.'], 404);
        }

        return new ShopResource($shop);
    }
}

```

```php
<?php

// app/Domain/Shops/Controllers/SellerShopController.php

namespace App\Domain\Shops\Controllers;

use App\Domain\Shops\Models\Shop;
use App\Domain\Shops\Requests\CreateShopRequest;
use App\Domain\Shops\Resources\ShopResource;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Support\Facades\DB;

class SellerShopController
{
    public function store(CreateShopRequest $request)
    {
        $seller = $request->user();
        $data = $request->validated();

        $existing = Shop::query()->where('seller_user_id', $seller->id)->first();
        if ($existing) {
            return response()->json(['message' => 'Seller already has a shop.'], 409);
        }

        $operationalZoneId = UserZone::query()
            ->where('user_id', $seller->id)
            ->where('type', 'operational')
            ->value('zone_id');

        if (! $operationalZoneId) {
            return response()->json(['message' => 'Operational zone is required for sellers.'], 422);
        }

        if ((int) $operationalZoneId !== (int) $data['zone_id']) {
            return response()->json(['message' => 'Shop zone must match seller operational zone.'], 422);
        }

        $shop = DB::transaction(function () use ($seller, $data) {
            return Shop::create([
                'seller_user_id' => $seller->id,
                'shop_name' => $data['shop_name'],
                'description' => $data['description'] ?? null,
                'zone_id' => $data['zone_id'],
                'address_text' => $data['address_text'],
                'is_verified' => false,
                'verification_phase' => 'phase1',
            ]);
        });

        return new ShopResource($shop);
    }
}

```

```php
<?php

// app/Domain/Shops/Enums/ShopVerificationPhase.php

namespace App\Domain\Shops\Enums;

enum ShopVerificationPhase: string
{
    case Phase1 = 'phase1';
    case Phase2 = 'phase2';
}

```

```php
<?php

// app/Domain/Shops/Models/SellerBankAccount.php

namespace App\Domain\Shops\Models;

use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SellerBankAccount extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'verified_at' => 'datetime',
        ];
    }

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_user_id');
    }
}

```

```php
<?php

// app/Domain/Shops/Models/Shop.php

namespace App\Domain\Shops\Models;

use App\Domain\Products\Models\Product;
use App\Domain\Shops\Enums\ShopVerificationPhase;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Shop extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'is_verified' => 'boolean',
            'verification_phase' => ShopVerificationPhase::class,
        ];
    }

    public function seller()
    {
        return $this->belongsTo(User::class, 'seller_user_id');
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }

    public function products()
    {
        return $this->hasMany(Product::class);
    }
}

```

```php
<?php

// app/Domain/Shops/Requests/CreateShopRequest.php

namespace App\Domain\Shops\Requests;

use Illuminate\Foundation\Http\FormRequest;

class CreateShopRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'shop_name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string', 'max:2000'],
            'zone_id' => ['required', 'integer', 'exists:zones,id'],
            'address_text' => ['required', 'string', 'max:255'],
        ];
    }
}

```

```php
<?php

// app/Domain/Shops/Resources/ShopResource.php

namespace App\Domain\Shops\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ShopResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Shops\Models\Shop $shop */
        $shop = $this->resource;

        return [
            'id' => $shop->id,
            'seller_user_id' => $shop->seller_user_id,
            'shop_name' => $shop->shop_name,
            'description' => $shop->description,
            'zone_id' => $shop->zone_id,
            'address_text' => $shop->address_text,
            'is_verified' => (bool) $shop->is_verified,
            'verification_phase' => $shop->verification_phase->value,
            'created_at' => optional($shop->created_at)?->toISOString(),
        ];
    }
}

```

```php
<?php

// app/Domain/Users/Controllers/UserZoneController.php

namespace App\Domain\Users\Controllers;

use App\Domain\Users\Requests\SetUserZoneRequest;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;

class UserZoneController
{
    public function store(SetUserZoneRequest $request)
    {
        $user = $request->user();
        $data = $request->validated();

        /** @var Zone $zone */
        $zone = Zone::query()->where('id', $data['zone_id'])->where('is_active', true)->firstOrFail();

        $record = UserZone::updateOrCreate(
            ['user_id' => $user->id, 'type' => $data['type']],
            ['zone_id' => $zone->id],
        );

        return response()->json([
            'message' => 'Zone updated.',
            'user_zone' => [
                'id' => $record->id,
                'type' => $record->type,
                'zone_id' => $record->zone_id,
            ],
        ]);
    }
}

```

```php
<?php

// app/Domain/Users/Enums/UserRole.php

namespace App\Domain\Users\Enums;

enum UserRole: string
{
    case Buyer = 'buyer';
    case Seller = 'seller';
    case Rider = 'rider';
    case Admin = 'admin';
}

```

```php
<?php

// app/Domain/Users/Enums/UserStatus.php

namespace App\Domain\Users\Enums;

enum UserStatus: string
{
    case Pending = 'pending';
    case Active = 'active';
    case Suspended = 'suspended';
    case Banned = 'banned';
}

```

```php
<?php

// app/Domain/Users/Models/User.php

namespace App\Domain\Users\Models;

use App\Domain\Kyc\Models\KycRequest;
use App\Domain\Orders\Models\Order;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Wallet\Models\WalletAccount;
use App\Domain\Zones\Models\UserZone;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;
    use HasFactory;
    use Notifiable;

    protected $guarded = [];

    protected $hidden = [
        'password',
    ];

    protected function casts(): array
    {
        return [
            'role' => UserRole::class,
            'status' => UserStatus::class,
            'phone_verified_at' => 'datetime',
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    protected static function booted(): void
    {
        static::created(function (self $user): void {
            WalletAccount::firstOrCreate(
                ['user_id' => $user->id],
                [
                    'currency' => (string) config('smartlink.currency', 'NGN'),
                    'available_balance' => 0,
                    'status' => 'active',
                ],
            );
        });
    }

    public function walletAccount()
    {
        return $this->hasOne(WalletAccount::class);
    }

    public function shop()
    {
        return $this->hasOne(Shop::class, 'seller_user_id');
    }

    public function kycRequests()
    {
        return $this->hasMany(KycRequest::class);
    }

    public function buyerOrders()
    {
        return $this->hasMany(Order::class, 'buyer_user_id');
    }

    public function zones()
    {
        return $this->hasMany(UserZone::class);
    }

    public function hasVerifiedPhone(): bool
    {
        return $this->phone_verified_at !== null;
    }
}
```

```php
<?php

// app/Domain/Users/Requests/SetUserZoneRequest.php

namespace App\Domain\Users\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class SetUserZoneRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'zone_id' => ['required', 'integer', 'exists:zones,id'],
            'type' => ['required', 'string', Rule::in(['home', 'operational'])],
        ];
    }
}

```

```php
<?php

// app/Domain/Users/Resources/UserResource.php

namespace App\Domain\Users\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Users\Models\User $user */
        $user = $this->resource;

        return [
            'id' => $user->id,
            'full_name' => $user->full_name,
            'phone' => $user->phone,
            'email' => $user->email,
            'role' => $user->role->value,
            'status' => $user->status->value,
            'phone_verified_at' => optional($user->phone_verified_at)?->toISOString(),
            'email_verified_at' => optional($user->email_verified_at)?->toISOString(),
            'created_at' => optional($user->created_at)?->toISOString(),
        ];
    }
}

```

```php
<?php

// app/Domain/Wallet/Controllers/WalletController.php

namespace App\Domain\Wallet\Controllers;

use App\Domain\Payments\Services\PaystackService;
use App\Domain\Wallet\Requests\InitiateTopupRequest;
use App\Domain\Wallet\Resources\WalletAccountResource;
use App\Domain\Wallet\Resources\WalletTransactionResource;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Http\Request;

class WalletController
{
    public function __construct(
        private readonly WalletService $walletService,
        private readonly PaystackService $paystackService,
    ) {
    }

    public function show(Request $request)
    {
        $user = $request->user();

        $this->walletService->requireVerifiedForWallet($user);

        $wallet = $this->walletService->walletFor($user);

        return new WalletAccountResource($wallet);
    }

    public function transactions(Request $request)
    {
        $user = $request->user();

        $this->walletService->requireVerifiedForWallet($user);

        $wallet = $this->walletService->walletFor($user);

        $items = $wallet->transactions()
            ->latest('id')
            ->paginate(50);

        return WalletTransactionResource::collection($items);
    }

    public function initiateTopup(InitiateTopupRequest $request)
    {
        $user = $request->user();

        $this->walletService->requireVerifiedForWallet($user);

        $data = $request->validated();

        $init = $this->paystackService->initializeTopup($user, (float) $data['amount']);

        return response()->json([
            'authorization_url' => $init['authorization_url'],
            'reference' => $init['reference'],
        ]);
    }
}

```

```php
<?php

// app/Domain/Wallet/Enums/WalletAccountStatus.php

namespace App\Domain\Wallet\Enums;

enum WalletAccountStatus: string
{
    case Active = 'active';
    case Frozen = 'frozen';
}

```

```php
<?php

// app/Domain/Wallet/Enums/WalletTransactionDirection.php

namespace App\Domain\Wallet\Enums;

enum WalletTransactionDirection: string
{
    case In = 'in';
    case Out = 'out';
}

```

```php
<?php

// app/Domain/Wallet/Enums/WalletTransactionType.php

namespace App\Domain\Wallet\Enums;

enum WalletTransactionType: string
{
    case Topup = 'topup';
    case Debit = 'debit';
    case Credit = 'credit';
    case Hold = 'hold';
    case Release = 'release';
    case Refund = 'refund';
    case Fee = 'fee';
}

```

```php
<?php

// app/Domain/Wallet/Models/WalletAccount.php

namespace App\Domain\Wallet\Models;

use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletAccountStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WalletAccount extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'available_balance' => 'decimal:2',
            'status' => WalletAccountStatus::class,
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function transactions()
    {
        return $this->hasMany(WalletTransaction::class);
    }
}

```

```php
<?php

// app/Domain/Wallet/Models/WalletTransaction.php

namespace App\Domain\Wallet\Models;

use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WalletTransaction extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'type' => WalletTransactionType::class,
            'direction' => WalletTransactionDirection::class,
            'amount' => 'decimal:2',
            'meta_json' => 'array',
        ];
    }

    public function walletAccount()
    {
        return $this->belongsTo(WalletAccount::class);
    }
}

```

```php
<?php

// app/Domain/Wallet/Requests/InitiateTopupRequest.php

namespace App\Domain\Wallet\Requests;

use Illuminate\Foundation\Http\FormRequest;

class InitiateTopupRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'amount' => ['required', 'numeric', 'min:100'],
        ];
    }
}

```

```php
<?php

// app/Domain/Wallet/Resources/WalletAccountResource.php

namespace App\Domain\Wallet\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WalletAccountResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Wallet\Models\WalletAccount $wallet */
        $wallet = $this->resource;

        return [
            'id' => $wallet->id,
            'currency' => $wallet->currency,
            'available_balance' => (string) $wallet->available_balance,
            'status' => $wallet->status->value,
            'created_at' => optional($wallet->created_at)?->toISOString(),
        ];
    }
}

```

```php
<?php

// app/Domain/Wallet/Resources/WalletTransactionResource.php

namespace App\Domain\Wallet\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class WalletTransactionResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Wallet\Models\WalletTransaction $tx */
        $tx = $this->resource;

        return [
            'id' => $tx->id,
            'type' => $tx->type->value,
            'direction' => $tx->direction->value,
            'amount' => (string) $tx->amount,
            'reference' => $tx->reference,
            'meta' => $tx->meta_json,
            'created_at' => optional($tx->created_at)?->toISOString(),
        ];
    }
}

```

```php
<?php

// app/Domain/Wallet/Services/WalletService.php

namespace App\Domain\Wallet\Services;

use App\Domain\Audit\Services\AuditLogger;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletAccountStatus;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Models\WalletAccount;
use App\Domain\Wallet\Models\WalletTransaction;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class WalletService
{
    public function __construct(private readonly AuditLogger $auditLogger)
    {
    }

    public function requireVerifiedForWallet(User $user): void
    {
        if (! $user->hasVerifiedPhone()) {
            throw new \RuntimeException('Phone verification required.');
        }
    }

    public function walletFor(User $user): WalletAccount
    {
        return WalletAccount::firstOrCreate(
            ['user_id' => $user->id],
            [
                'currency' => (string) config('smartlink.currency', 'NGN'),
                'available_balance' => 0,
                'status' => WalletAccountStatus::Active,
            ],
        );
    }

    /**
     * Idempotent ledger writer (unique reference).
     */
    public function record(
        WalletAccount $walletAccount,
        WalletTransactionType $type,
        WalletTransactionDirection $direction,
        float $amount,
        string $reference,
        ?string $relatedEntityType = null,
        ?int $relatedEntityId = null,
        array $meta = [],
    ): WalletTransaction {
        return DB::transaction(function () use ($walletAccount, $type, $direction, $amount, $reference, $relatedEntityType, $relatedEntityId, $meta) {
            $existing = WalletTransaction::query()->where('reference', $reference)->first();
            if ($existing) {
                return $existing;
            }

            /** @var WalletAccount $locked */
            $locked = WalletAccount::query()->whereKey($walletAccount->id)->lockForUpdate()->firstOrFail();

            if ($locked->status === WalletAccountStatus::Frozen) {
                throw new \RuntimeException('Wallet is frozen.');
            }

            $amount = round($amount, 2);
            if ($amount <= 0) {
                throw new \InvalidArgumentException('Amount must be positive.');
            }

            $newBalance = $locked->available_balance;

            if ($direction === WalletTransactionDirection::In) {
                $newBalance = $locked->available_balance + $amount;
            } else {
                if ($locked->available_balance < $amount) {
                    throw new \RuntimeException('Insufficient wallet balance.');
                }
                $newBalance = $locked->available_balance - $amount;
            }

            try {
                $tx = WalletTransaction::create([
                    'wallet_account_id' => $locked->id,
                    'type' => $type,
                    'direction' => $direction,
                    'amount' => $amount,
                    'reference' => $reference,
                    'related_entity_type' => $relatedEntityType,
                    'related_entity_id' => $relatedEntityId,
                    'meta_json' => $meta === [] ? null : $meta,
                ]);
            } catch (QueryException $e) {
                $existing = WalletTransaction::query()->where('reference', $reference)->first();
                if ($existing) {
                    return $existing;
                }
                throw $e;
            }

            $locked->forceFill(['available_balance' => $newBalance])->save();

            $this->auditLogger->log(
                isset($meta['actor_user_id']) ? (int) $meta['actor_user_id'] : null,
                'wallet.transaction.created',
                $tx,
                [
                    'wallet_account_id' => $locked->id,
                    'type' => $type->value,
                    'direction' => $direction->value,
                    'amount' => $amount,
                    'reference' => $reference,
                    'related_entity_type' => $relatedEntityType,
                    'related_entity_id' => $relatedEntityId,
                ],
            );

            return $tx;
        });
    }
}
```

```php
<?php

// app/Domain/Webhooks/Controllers/PaystackWebhookController.php

namespace App\Domain\Webhooks\Controllers;

use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaystackWebhookController
{
    public function __construct(private readonly WalletService $walletService)
    {
    }

    public function handle(Request $request)
    {
        $secret = (string) config('smartlink.paystack.webhook_secret');
        $signature = (string) $request->header('x-paystack-signature', '');
        $payload = (string) $request->getContent();

        if ($secret === '' || $signature === '' || ! hash_equals(hash_hmac('sha512', $payload, $secret), $signature)) {
            return response()->json(['message' => 'Invalid signature.'], 401);
        }

        $event = (string) data_get($request->json()->all(), 'event', '');

        if ($event !== 'charge.success') {
            return response()->json(['message' => 'Ignored.']);
        }

        $data = $request->json('data');

        $status = (string) data_get($data, 'status', '');
        if ($status !== 'success') {
            return response()->json(['message' => 'Ignored.']);
        }

        $reference = (string) data_get($data, 'reference', '');
        $amountKobo = (int) data_get($data, 'amount', 0);
        $userId = (int) data_get($data, 'metadata.user_id', 0);

        if ($reference === '' || $amountKobo <= 0 || $userId <= 0) {
            Log::warning('Paystack webhook missing required fields', ['reference' => $reference, 'user_id' => $userId]);
            return response()->json(['message' => 'Ignored.']);
        }

        /** @var User|null $user */
        $user = User::query()->find($userId);
        if (! $user) {
            return response()->json(['message' => 'Ignored.']);
        }

        $wallet = $this->walletService->walletFor($user);
        $amount = $amountKobo / 100;

        $this->walletService->record(
            $wallet,
            WalletTransactionType::Topup,
            WalletTransactionDirection::In,
            $amount,
            $reference,
            relatedEntityType: 'paystack',
            relatedEntityId: (int) data_get($data, 'id', 0) ?: null,
            meta: [
                'event' => $event,
                'channel' => data_get($data, 'channel'),
                'paid_at' => data_get($data, 'paid_at'),
            ],
        );

        return response()->json(['message' => 'OK']);
    }
}

```

```php
<?php

// app/Domain/Zones/Controllers/ZoneController.php

namespace App\Domain\Zones\Controllers;

use App\Domain\Zones\Models\Zone;
use App\Domain\Zones\Resources\ZoneResource;
use Illuminate\Support\Facades\Cache;

class ZoneController
{
    public function index()
    {
        $zones = Cache::remember('zones:active', 300, function () {
            return Zone::query()
                ->where('is_active', true)
                ->orderBy('state')
                ->orderBy('city')
                ->orderBy('name')
                ->get();
        });

        return ZoneResource::collection($zones);
    }
}

```

```php
<?php

// app/Domain/Zones/Models/UserZone.php

namespace App\Domain\Zones\Models;

use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class UserZone extends Model
{
    use HasFactory;

    protected $table = 'user_zones';

    protected $guarded = [];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function zone()
    {
        return $this->belongsTo(Zone::class);
    }
}

```

```php
<?php

// app/Domain/Zones/Models/Zone.php

namespace App\Domain\Zones\Models;

use App\Domain\Orders\Models\Order;
use App\Domain\Shops\Models\Shop;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Zone extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected function casts(): array
    {
        return [
            'polygon_geojson' => 'array',
            'is_active' => 'boolean',
        ];
    }

    public function shops()
    {
        return $this->hasMany(Shop::class);
    }

    public function orders()
    {
        return $this->hasMany(Order::class);
    }
}

```

```php
<?php

// app/Domain/Zones/Resources/ZoneResource.php

namespace App\Domain\Zones\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ZoneResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var \App\Domain\Zones\Models\Zone $zone */
        $zone = $this->resource;

        return [
            'id' => $zone->id,
            'name' => $zone->name,
            'city' => $zone->city,
            'state' => $zone->state,
            'is_active' => (bool) $zone->is_active,
        ];
    }
}

```

```php
<?php

// app/Http/Middleware/EnsureRole.php

namespace App\Http\Middleware;

use BackedEnum;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRole
{
    /**
     * @param  list<string>  ...$roles
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();

        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        if ($roles === []) {
            return $next($request);
        }

        $role = $user->role instanceof BackedEnum ? $user->role->value : (string) $user->role;

        if (! in_array($role, $roles, true)) {
            return response()->json(['message' => 'Forbidden.'], 403);
        }

        return $next($request);
    }
}

```

```php
<?php

// app/Http/Middleware/EnsureUserStatus.php

namespace App\Http\Middleware;

use BackedEnum;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureUserStatus
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if ($user) {
            $status = $user->status instanceof BackedEnum ? $user->status->value : (string) $user->status;

            if (in_array($status, ['suspended', 'banned'], true)) {
                return response()->json(['message' => 'Account is not active.'], 403);
            }
        }

        return $next($request);
    }
}

```

```php
<?php

// app/Providers/AppServiceProvider.php

namespace App\Providers;

use App\Domain\Notifications\Contracts\OtpProvider;
use App\Domain\Notifications\Providers\LogOtpProvider;
use App\Domain\Notifications\Providers\SendchampOtpProvider;
use App\Domain\Notifications\Providers\TermiiOtpProvider;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\RateLimiter;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(OtpProvider::class, function () {
            return match (config('smartlink.otp.driver')) {
                'termii' => $this->app->make(TermiiOtpProvider::class),
                'sendchamp' => $this->app->make(SendchampOtpProvider::class),
                default => $this->app->make(LogOtpProvider::class),
            };
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('auth', function (Request $request) {
            $key = $request->ip().'|'.(string) $request->input('phone', $request->input('email', ''));

            return Limit::perMinute(10)->by($key);
        });

        RateLimiter::for('otp', function (Request $request) {
            $key = 'otp|'.$request->ip().'|'.(string) $request->input('phone', '');

            return Limit::perMinute(5)->by($key);
        });
    }
}
```

```php
<?php

// app/Providers/AuthServiceProvider.php

namespace App\Providers;

use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Dispatch\Policies\DispatchJobPolicy;
use App\Domain\Orders\Models\Order;
use App\Domain\Orders\Policies\OrderPolicy;
use App\Domain\Products\Models\Product;
use App\Domain\Products\Policies\ProductPolicy;
use Illuminate\Foundation\Support\Providers\AuthServiceProvider as ServiceProvider;

class AuthServiceProvider extends ServiceProvider
{
    /**
     * @var array<class-string, class-string>
     */
    protected $policies = [
        Order::class => OrderPolicy::class,
        Product::class => ProductPolicy::class,
        DispatchJob::class => DispatchJobPolicy::class,
    ];

    public function boot(): void
    {
        $this->registerPolicies();
    }
}

```

```php
<?php

// bootstrap/app.php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'role' => \App\Http\Middleware\EnsureRole::class,
        ]);

        $middleware->appendToGroup('api', [
            \App\Http\Middleware\EnsureUserStatus::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
```

```php
<?php

// bootstrap/providers.php

return [
    App\Providers\AppServiceProvider::class,
    App\Providers\AuthServiceProvider::class,
];
```

```php
<?php

// config/auth.php

return [

    /*
    |--------------------------------------------------------------------------
    | Authentication Defaults
    |--------------------------------------------------------------------------
    |
    | This option defines the default authentication "guard" and password
    | reset "broker" for your application. You may change these values
    | as required, but they're a perfect start for most applications.
    |
    */

    'defaults' => [
        'guard' => env('AUTH_GUARD', 'sanctum'),
        'passwords' => env('AUTH_PASSWORD_BROKER', 'users'),
    ],

    /*
    |--------------------------------------------------------------------------
    | Authentication Guards
    |--------------------------------------------------------------------------
    |
    | Next, you may define every authentication guard for your application.
    | Of course, a great default configuration has been defined for you
    | which utilizes session storage plus the Eloquent user provider.
    |
    | All authentication guards have a user provider, which defines how the
    | users are actually retrieved out of your database or other storage
    | system used by the application. Typically, Eloquent is utilized.
    |
    | Supported: "session"
    |
    */

    'guards' => [
        'web' => [
            'driver' => 'session',
            'provider' => 'users',
        ],

        'sanctum' => [
            'driver' => 'sanctum',
            'provider' => 'users',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | User Providers
    |--------------------------------------------------------------------------
    |
    | All authentication guards have a user provider, which defines how the
    | users are actually retrieved out of your database or other storage
    | system used by the application. Typically, Eloquent is utilized.
    |
    | If you have multiple user tables or models you may configure multiple
    | providers to represent the model / table. These providers may then
    | be assigned to any extra authentication guards you have defined.
    |
    | Supported: "database", "eloquent"
    |
    */

    'providers' => [
        'users' => [
            'driver' => 'eloquent',
            'model' => env('AUTH_MODEL', App\Domain\Users\Models\User::class),
        ],

        // 'users' => [
        //     'driver' => 'database',
        //     'table' => 'users',
        // ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Resetting Passwords
    |--------------------------------------------------------------------------
    |
    | These configuration options specify the behavior of Laravel's password
    | reset functionality, including the table utilized for token storage
    | and the user provider that is invoked to actually retrieve users.
    |
    | The expiry time is the number of minutes that each reset token will be
    | considered valid. This security feature keeps tokens short-lived so
    | they have less time to be guessed. You may change this as needed.
    |
    | The throttle setting is the number of seconds a user must wait before
    | generating more password reset tokens. This prevents the user from
    | quickly generating a very large amount of password reset tokens.
    |
    */

    'passwords' => [
        'users' => [
            'provider' => 'users',
            'table' => env('AUTH_PASSWORD_RESET_TOKEN_TABLE', 'password_reset_tokens'),
            'expire' => 60,
            'throttle' => 60,
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Password Confirmation Timeout
    |--------------------------------------------------------------------------
    |
    | Here you may define the amount of seconds before a password confirmation
    | window expires and users are asked to re-enter their password via the
    | confirmation screen. By default, the timeout lasts for three hours.
    |
    */

    'password_timeout' => env('AUTH_PASSWORD_TIMEOUT', 10800),

];
```

```php
<?php

// config/cache.php

use Illuminate\Support\Str;

return [

    /*
    |--------------------------------------------------------------------------
    | Default Cache Store
    |--------------------------------------------------------------------------
    |
    | This option controls the default cache store that will be used by the
    | framework. This connection is utilized if another isn't explicitly
    | specified when running a cache operation inside the application.
    |
    */

    'default' => env('CACHE_STORE', 'redis'),

    /*
    |--------------------------------------------------------------------------
    | Cache Stores
    |--------------------------------------------------------------------------
    |
    | Here you may define all of the cache "stores" for your application as
    | well as their drivers. You may even define multiple stores for the
    | same cache driver to group types of items stored in your caches.
    |
    | Supported drivers: "array", "database", "file", "memcached",
    |                    "redis", "dynamodb", "octane", "null"
    |
    */

    'stores' => [

        'array' => [
            'driver' => 'array',
            'serialize' => false,
        ],

        'database' => [
            'driver' => 'database',
            'connection' => env('DB_CACHE_CONNECTION'),
            'table' => env('DB_CACHE_TABLE', 'cache'),
            'lock_connection' => env('DB_CACHE_LOCK_CONNECTION'),
            'lock_table' => env('DB_CACHE_LOCK_TABLE'),
        ],

        'file' => [
            'driver' => 'file',
            'path' => storage_path('framework/cache/data'),
            'lock_path' => storage_path('framework/cache/data'),
        ],

        'memcached' => [
            'driver' => 'memcached',
            'persistent_id' => env('MEMCACHED_PERSISTENT_ID'),
            'sasl' => [
                env('MEMCACHED_USERNAME'),
                env('MEMCACHED_PASSWORD'),
            ],
            'options' => [
                // Memcached::OPT_CONNECT_TIMEOUT => 2000,
            ],
            'servers' => [
                [
                    'host' => env('MEMCACHED_HOST', '127.0.0.1'),
                    'port' => env('MEMCACHED_PORT', 11211),
                    'weight' => 100,
                ],
            ],
        ],

        'redis' => [
            'driver' => 'redis',
            'connection' => env('REDIS_CACHE_CONNECTION', 'cache'),
            'lock_connection' => env('REDIS_CACHE_LOCK_CONNECTION', 'default'),
        ],

        'dynamodb' => [
            'driver' => 'dynamodb',
            'key' => env('AWS_ACCESS_KEY_ID'),
            'secret' => env('AWS_SECRET_ACCESS_KEY'),
            'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
            'table' => env('DYNAMODB_CACHE_TABLE', 'cache'),
            'endpoint' => env('DYNAMODB_ENDPOINT'),
        ],

        'octane' => [
            'driver' => 'octane',
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Cache Key Prefix
    |--------------------------------------------------------------------------
    |
    | When utilizing the APC, database, memcached, Redis, and DynamoDB cache
    | stores, there might be other applications using the same cache. For
    | that reason, you may prefix every cache key to avoid collisions.
    |
    */

    'prefix' => env('CACHE_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_cache_'),

];
```

```php
<?php

// config/database.php

use Illuminate\Support\Str;

return [

    /*
    |--------------------------------------------------------------------------
    | Default Database Connection Name
    |--------------------------------------------------------------------------
    |
    | Here you may specify which of the database connections below you wish
    | to use as your default connection for database operations. This is
    | the connection which will be utilized unless another connection
    | is explicitly specified when you execute a query / statement.
    |
    */

    'default' => env('DB_CONNECTION', 'sqlite'),

    /*
    |--------------------------------------------------------------------------
    | Database Connections
    |--------------------------------------------------------------------------
    |
    | Below are all of the database connections defined for your application.
    | An example configuration is provided for each database system which
    | is supported by Laravel. You're free to add / remove connections.
    |
    */

    'connections' => [

        'sqlite' => [
            'driver' => 'sqlite',
            'url' => env('DB_URL'),
            'database' => env('DB_DATABASE', database_path('database.sqlite')),
            'prefix' => '',
            'foreign_key_constraints' => env('DB_FOREIGN_KEYS', true),
            'busy_timeout' => null,
            'journal_mode' => null,
            'synchronous' => null,
        ],

        'mysql' => [
            'driver' => 'mysql',
            'url' => env('DB_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '3306'),
            'database' => env('DB_DATABASE', 'laravel'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'unix_socket' => env('DB_SOCKET', ''),
            'charset' => env('DB_CHARSET', 'utf8mb4'),
            'collation' => env('DB_COLLATION', 'utf8mb4_unicode_ci'),
            'prefix' => '',
            'prefix_indexes' => true,
            'strict' => true,
            'engine' => null,
            'options' => extension_loaded('pdo_mysql') ? array_filter([
                PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
            ]) : [],
        ],

        'mariadb' => [
            'driver' => 'mariadb',
            'url' => env('DB_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '3306'),
            'database' => env('DB_DATABASE', 'laravel'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'unix_socket' => env('DB_SOCKET', ''),
            'charset' => env('DB_CHARSET', 'utf8mb4'),
            'collation' => env('DB_COLLATION', 'utf8mb4_unicode_ci'),
            'prefix' => '',
            'prefix_indexes' => true,
            'strict' => true,
            'engine' => null,
            'options' => extension_loaded('pdo_mysql') ? array_filter([
                PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
            ]) : [],
        ],

        'pgsql' => [
            'driver' => 'pgsql',
            'url' => env('DB_URL'),
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', '5432'),
            'database' => env('DB_DATABASE', 'laravel'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => env('DB_CHARSET', 'utf8'),
            'prefix' => '',
            'prefix_indexes' => true,
            'search_path' => 'public',
            'sslmode' => 'prefer',
        ],

        'sqlsrv' => [
            'driver' => 'sqlsrv',
            'url' => env('DB_URL'),
            'host' => env('DB_HOST', 'localhost'),
            'port' => env('DB_PORT', '1433'),
            'database' => env('DB_DATABASE', 'laravel'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => env('DB_CHARSET', 'utf8'),
            'prefix' => '',
            'prefix_indexes' => true,
            // 'encrypt' => env('DB_ENCRYPT', 'yes'),
            // 'trust_server_certificate' => env('DB_TRUST_SERVER_CERTIFICATE', 'false'),
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Migration Repository Table
    |--------------------------------------------------------------------------
    |
    | This table keeps track of all the migrations that have already run for
    | your application. Using this information, we can determine which of
    | the migrations on disk haven't actually been run on the database.
    |
    */

    'migrations' => [
        'table' => 'migrations',
        'update_date_on_publish' => true,
    ],

    /*
    |--------------------------------------------------------------------------
    | Redis Databases
    |--------------------------------------------------------------------------
    |
    | Redis is an open source, fast, and advanced key-value store that also
    | provides a richer body of commands than a typical key-value system
    | such as Memcached. You may define your connection settings here.
    |
    */

    'redis' => [

        'client' => env('REDIS_CLIENT', 'predis'),

        'options' => [
            'cluster' => env('REDIS_CLUSTER', 'redis'),
            'prefix' => env('REDIS_PREFIX', Str::slug(env('APP_NAME', 'laravel'), '_').'_database_'),
        ],

        'default' => [
            'url' => env('REDIS_URL'),
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'username' => env('REDIS_USERNAME'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', '6379'),
            'database' => env('REDIS_DB', '0'),
        ],

        'cache' => [
            'url' => env('REDIS_URL'),
            'host' => env('REDIS_HOST', '127.0.0.1'),
            'username' => env('REDIS_USERNAME'),
            'password' => env('REDIS_PASSWORD'),
            'port' => env('REDIS_PORT', '6379'),
            'database' => env('REDIS_CACHE_DB', '1'),
        ],

    ],

];
```

```php
<?php

// config/queue.php

return [

    /*
    |--------------------------------------------------------------------------
    | Default Queue Connection Name
    |--------------------------------------------------------------------------
    |
    | Laravel's queue supports a variety of backends via a single, unified
    | API, giving you convenient access to each backend using identical
    | syntax for each. The default queue connection is defined below.
    |
    */

    'default' => env('QUEUE_CONNECTION', 'redis'),

    /*
    |--------------------------------------------------------------------------
    | Queue Connections
    |--------------------------------------------------------------------------
    |
    | Here you may configure the connection options for every queue backend
    | used by your application. An example configuration is provided for
    | each backend supported by Laravel. You're also free to add more.
    |
    | Drivers: "sync", "database", "beanstalkd", "sqs", "redis", "null"
    |
    */

    'connections' => [

        'sync' => [
            'driver' => 'sync',
        ],

        'database' => [
            'driver' => 'database',
            'connection' => env('DB_QUEUE_CONNECTION'),
            'table' => env('DB_QUEUE_TABLE', 'jobs'),
            'queue' => env('DB_QUEUE', 'default'),
            'retry_after' => (int) env('DB_QUEUE_RETRY_AFTER', 90),
            'after_commit' => false,
        ],

        'beanstalkd' => [
            'driver' => 'beanstalkd',
            'host' => env('BEANSTALKD_QUEUE_HOST', 'localhost'),
            'queue' => env('BEANSTALKD_QUEUE', 'default'),
            'retry_after' => (int) env('BEANSTALKD_QUEUE_RETRY_AFTER', 90),
            'block_for' => 0,
            'after_commit' => false,
        ],

        'sqs' => [
            'driver' => 'sqs',
            'key' => env('AWS_ACCESS_KEY_ID'),
            'secret' => env('AWS_SECRET_ACCESS_KEY'),
            'prefix' => env('SQS_PREFIX', 'https://sqs.us-east-1.amazonaws.com/your-account-id'),
            'queue' => env('SQS_QUEUE', 'default'),
            'suffix' => env('SQS_SUFFIX'),
            'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
            'after_commit' => false,
        ],

        'redis' => [
            'driver' => 'redis',
            'connection' => env('REDIS_QUEUE_CONNECTION', 'default'),
            'queue' => env('REDIS_QUEUE', 'default'),
            'retry_after' => (int) env('REDIS_QUEUE_RETRY_AFTER', 90),
            'block_for' => null,
            'after_commit' => false,
        ],

    ],

    /*
    |--------------------------------------------------------------------------
    | Job Batching
    |--------------------------------------------------------------------------
    |
    | The following options configure the database and table that store job
    | batching information. These options can be updated to any database
    | connection and table which has been defined by your application.
    |
    */

    'batching' => [
        'database' => env('DB_CONNECTION', 'sqlite'),
        'table' => 'job_batches',
    ],

    /*
    |--------------------------------------------------------------------------
    | Failed Queue Jobs
    |--------------------------------------------------------------------------
    |
    | These options configure the behavior of failed queue job logging so you
    | can control how and where failed jobs are stored. Laravel ships with
    | support for storing failed jobs in a simple file or in a database.
    |
    | Supported drivers: "database-uuids", "dynamodb", "file", "null"
    |
    */

    'failed' => [
        'driver' => env('QUEUE_FAILED_DRIVER', 'database-uuids'),
        'database' => env('DB_CONNECTION', 'sqlite'),
        'table' => 'failed_jobs',
    ],

];
```

```php
<?php

// config/sanctum.php

use Laravel\Sanctum\Sanctum;

return [

    /*
    |--------------------------------------------------------------------------
    | Stateful Domains
    |--------------------------------------------------------------------------
    |
    | Requests from the following domains / hosts will receive stateful API
    | authentication cookies. Typically, these should include your local
    | and production domains which access your API via a frontend SPA.
    |
    */

    'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
        '%s%s',
        'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
        Sanctum::currentApplicationUrlWithPort(),
        // Sanctum::currentRequestHost(),
    ))),

    /*
    |--------------------------------------------------------------------------
    | Sanctum Guards
    |--------------------------------------------------------------------------
    |
    | This array contains the authentication guards that will be checked when
    | Sanctum is trying to authenticate a request. If none of these guards
    | are able to authenticate the request, Sanctum will use the bearer
    | token that's present on an incoming request for authentication.
    |
    */

    'guard' => ['web'],

    /*
    |--------------------------------------------------------------------------
    | Expiration Minutes
    |--------------------------------------------------------------------------
    |
    | This value controls the number of minutes until an issued token will be
    | considered expired. This will override any values set in the token's
    | "expires_at" attribute, but first-party sessions are not affected.
    |
    */

    'expiration' => null,

    /*
    |--------------------------------------------------------------------------
    | Token Prefix
    |--------------------------------------------------------------------------
    |
    | Sanctum can prefix new tokens in order to take advantage of numerous
    | security scanning initiatives maintained by open source platforms
    | that notify developers if they commit tokens into repositories.
    |
    | See: https://docs.github.com/en/code-security/secret-scanning/about-secret-scanning
    |
    */

    'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),

    /*
    |--------------------------------------------------------------------------
    | Sanctum Middleware
    |--------------------------------------------------------------------------
    |
    | When authenticating your first-party SPA with Sanctum you may need to
    | customize some of the middleware Sanctum uses while processing the
    | request. You may change the middleware listed below as required.
    |
    */

    'middleware' => [
        'authenticate_session' => Laravel\Sanctum\Http\Middleware\AuthenticateSession::class,
        'encrypt_cookies' => Illuminate\Cookie\Middleware\EncryptCookies::class,
        'validate_csrf_token' => Illuminate\Foundation\Http\Middleware\ValidateCsrfToken::class,
    ],

];
```

```php
<?php

// config/smartlink.php

return [
    'currency' => env('SMARTLINK_CURRENCY', 'NGN'),
    'media_disk' => env('SMARTLINK_MEDIA_DISK', env('FILESYSTEM_DISK', 'local')),

    'escrow' => [
        'auto_release_hours' => (int) env('SMARTLINK_ESCROW_AUTO_RELEASE_HOURS', 24),
    ],

    'dispatch' => [
        'private_pool_minutes' => (int) env('SMARTLINK_DISPATCH_PRIVATE_POOL_MINUTES', 10),
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

```

```php
<?php

// database/factories/UserFactory.php

namespace Database\Factories;

use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Domain\Users\Models\User>
 */
class UserFactory extends Factory
{
    protected $model = User::class;

    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'full_name' => fake()->name(),
            'phone' => '0'.fake()->unique()->numberBetween(7000000000, 9099999999),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'phone_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
```

```php
<?php

// database/migrations/0001_01_01_000000_create_users_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('full_name');
            $table->string('phone', 32)->unique();
            $table->string('email')->nullable()->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamp('phone_verified_at')->nullable();
            $table->string('password');
            $table->enum('role', ['buyer', 'seller', 'rider', 'admin'])->default('buyer');
            $table->enum('status', ['pending', 'active', 'suspended', 'banned'])->default('pending');
            $table->timestamps();
        });

        Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        // Sessions table intentionally omitted (API-only).
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
        Schema::dropIfExists('password_reset_tokens');
    }
};
```

```php
<?php

// database/migrations/0001_01_01_000001_create_cache_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('cache', function (Blueprint $table) {
            $table->string('key')->primary();
            $table->mediumText('value');
            $table->integer('expiration');
        });

        Schema::create('cache_locks', function (Blueprint $table) {
            $table->string('key')->primary();
            $table->string('owner');
            $table->integer('expiration');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('cache');
        Schema::dropIfExists('cache_locks');
    }
};
```

```php
<?php

// database/migrations/0001_01_01_000002_create_jobs_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('jobs', function (Blueprint $table) {
            $table->id();
            $table->string('queue')->index();
            $table->longText('payload');
            $table->unsignedTinyInteger('attempts');
            $table->unsignedInteger('reserved_at')->nullable();
            $table->unsignedInteger('available_at');
            $table->unsignedInteger('created_at');
        });

        Schema::create('job_batches', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('name');
            $table->integer('total_jobs');
            $table->integer('pending_jobs');
            $table->integer('failed_jobs');
            $table->longText('failed_job_ids');
            $table->mediumText('options')->nullable();
            $table->integer('cancelled_at')->nullable();
            $table->integer('created_at');
            $table->integer('finished_at')->nullable();
        });

        Schema::create('failed_jobs', function (Blueprint $table) {
            $table->id();
            $table->string('uuid')->unique();
            $table->text('connection');
            $table->text('queue');
            $table->longText('payload');
            $table->longText('exception');
            $table->timestamp('failed_at')->useCurrent();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('jobs');
        Schema::dropIfExists('job_batches');
        Schema::dropIfExists('failed_jobs');
    }
};
```

```php
<?php

// database/migrations/2026_01_26_103154_create_personal_access_tokens_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('personal_access_tokens', function (Blueprint $table) {
            $table->id();
            $table->morphs('tokenable');
            $table->text('name');
            $table->string('token', 64)->unique();
            $table->text('abilities')->nullable();
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('expires_at')->nullable()->index();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('personal_access_tokens');
    }
};
```

```php
<?php

// database/migrations/2026_01_26_120000_create_smartlink_core_tables.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('zones', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('city');
            $table->string('state');
            $table->json('polygon_geojson')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('user_zones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->foreignId('zone_id')->constrained('zones');
            $table->enum('type', ['home', 'operational']);
            $table->timestamps();

            $table->unique(['user_id', 'type']);
        });

        Schema::create('shops', function (Blueprint $table) {
            $table->id();
            $table->foreignId('seller_user_id')->constrained('users');
            $table->string('shop_name');
            $table->text('description')->nullable();
            $table->foreignId('zone_id')->constrained('zones');
            $table->string('address_text');
            $table->boolean('is_verified')->default(false);
            $table->enum('verification_phase', ['phase1', 'phase2'])->default('phase1');
            $table->timestamps();

            $table->unique('seller_user_id');
            $table->index(['zone_id', 'is_verified']);
        });

        Schema::create('seller_bank_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('seller_user_id')->constrained('users');
            $table->string('bank_name');
            $table->string('account_number');
            $table->string('account_name');
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();

            $table->unique('seller_user_id');
        });

        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shop_id')->constrained('shops');
            $table->string('name');
            $table->text('description')->nullable();
            $table->decimal('price', 14, 2);
            $table->string('currency', 3)->default('NGN');
            $table->integer('stock_qty')->default(0);
            $table->enum('status', ['active', 'inactive', 'out_of_stock'])->default('active');
            $table->timestamps();

            $table->index(['shop_id', 'status']);
        });

        Schema::create('product_images', function (Blueprint $table) {
            $table->id();
            $table->foreignId('product_id')->constrained('products')->cascadeOnDelete();
            $table->string('image_url');
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->index(['product_id', 'sort_order']);
        });

        Schema::create('rider_profiles', function (Blueprint $table) {
            $table->foreignId('rider_user_id')->primary()->constrained('users');
            $table->enum('vehicle_type', ['bike', 'car', 'tricycle']);
            $table->string('plate_number')->nullable();
            $table->boolean('is_elite')->default(false);
            $table->string('qr_code_token')->unique();
            $table->timestamps();
        });

        Schema::create('rider_availability', function (Blueprint $table) {
            $table->foreignId('rider_user_id')->primary()->constrained('users');
            $table->enum('status', ['offline', 'available', 'busy'])->default('offline');
            $table->timestamp('last_seen_at')->nullable();
        });

        Schema::create('seller_rider_pools', function (Blueprint $table) {
            $table->id();
            $table->foreignId('shop_id')->constrained('shops')->cascadeOnDelete();
            $table->foreignId('rider_user_id')->constrained('users');
            $table->enum('status', ['invited', 'active', 'removed'])->default('invited');
            $table->foreignId('added_by')->constrained('users');
            $table->timestamps();

            $table->unique(['shop_id', 'rider_user_id']);
        });

        Schema::create('wallet_accounts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->string('currency', 3)->default('NGN');
            $table->decimal('available_balance', 14, 2)->default(0);
            $table->enum('status', ['active', 'frozen'])->default('active');
            $table->timestamps();

            $table->unique('user_id');
        });

        Schema::create('wallet_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_account_id')->constrained('wallet_accounts');
            $table->enum('type', ['topup', 'debit', 'credit', 'hold', 'release', 'refund', 'fee']);
            $table->enum('direction', ['in', 'out']);
            $table->decimal('amount', 14, 2);
            $table->string('reference')->unique();
            $table->string('related_entity_type')->nullable();
            $table->unsignedBigInteger('related_entity_id')->nullable();
            $table->json('meta_json')->nullable();
            $table->timestamps();

            $table->index(['wallet_account_id', 'created_at']);
        });

        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('buyer_user_id')->constrained('users');
            $table->foreignId('shop_id')->constrained('shops');
            $table->foreignId('zone_id')->constrained('zones');
            $table->decimal('subtotal_amount', 14, 2);
            $table->decimal('delivery_fee_amount', 14, 2)->default(0);
            $table->decimal('total_amount', 14, 2);
            $table->enum('status', [
                'placed',
                'paid',
                'accepted_by_seller',
                'dispatching',
                'assigned_to_rider',
                'picked_up',
                'delivered',
                'confirmed',
                'cancelled',
                'disputed',
            ])->default('placed');
            $table->enum('payment_status', ['pending', 'paid', 'refunded'])->default('pending');
            $table->string('delivery_address_text');
            $table->timestamps();

            $table->index(['buyer_user_id', 'status']);
            $table->index(['shop_id', 'status']);
        });

        Schema::create('order_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('product_id')->constrained('products');
            $table->integer('qty');
            $table->decimal('unit_price', 14, 2);
            $table->decimal('line_total', 14, 2);
        });

        Schema::create('order_status_history', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->string('status');
            $table->foreignId('changed_by_user_id')->nullable()->constrained('users');
            $table->timestamps();

            $table->index(['order_id', 'created_at']);
        });

        Schema::create('escrow_holds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders');
            $table->foreignId('buyer_wallet_account_id')->constrained('wallet_accounts');
            $table->foreignId('seller_user_id')->constrained('users');
            $table->decimal('amount', 14, 2);
            $table->enum('status', ['held', 'released', 'frozen', 'refunded'])->default('held');
            $table->timestamp('hold_expires_at')->nullable();
            $table->timestamps();

            $table->unique('order_id');
            $table->index(['seller_user_id', 'status']);
        });

        Schema::create('payouts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('seller_user_id')->constrained('users');
            $table->foreignId('order_id')->constrained('orders');
            $table->decimal('amount', 14, 2);
            $table->enum('status', ['pending', 'processing', 'paid', 'failed'])->default('pending');
            $table->enum('provider', ['paystack', 'flutterwave'])->default('paystack');
            $table->string('provider_ref')->nullable();
            $table->timestamps();

            $table->unique('order_id');
        });

        Schema::create('dispatch_jobs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders');
            $table->foreignId('shop_id')->constrained('shops');
            $table->foreignId('zone_id')->constrained('zones');
            $table->enum('status', ['pending', 'broadcasting', 'assigned', 'expired', 'cancelled'])->default('pending');
            $table->foreignId('assigned_rider_user_id')->nullable()->constrained('users');
            $table->timestamp('private_pool_only_until')->nullable();
            $table->timestamp('fallback_broadcast_at')->nullable();
            $table->timestamps();

            $table->unique('order_id');
            $table->index(['zone_id', 'status']);
        });

        Schema::create('dispatch_offers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('dispatch_job_id')->constrained('dispatch_jobs')->cascadeOnDelete();
            $table->foreignId('rider_user_id')->constrained('users');
            $table->enum('offer_status', ['sent', 'seen', 'accepted', 'declined', 'expired'])->default('sent');
            $table->timestamp('offered_at');
            $table->timestamp('responded_at')->nullable();

            $table->unique(['dispatch_job_id', 'rider_user_id']);
            $table->index(['rider_user_id', 'offer_status']);
        });

        Schema::create('order_evidence', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->enum('type', ['pickup_video', 'delivery_photo']);
            $table->string('file_url');
            $table->foreignId('captured_by_user_id')->constrained('users');
            $table->timestamps();
        });

        Schema::create('disputes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders');
            $table->foreignId('raised_by_user_id')->constrained('users');
            $table->enum('reason', ['wrong_item', 'damaged_item', 'not_delivered', 'other']);
            $table->text('description')->nullable();
            $table->enum('status', ['open', 'under_review', 'resolved', 'rejected'])->default('open');
            $table->foreignId('resolved_by_admin_id')->nullable()->constrained('users');
            $table->enum('resolution', [
                'refund_buyer',
                'pay_seller',
                'partial_refund',
                'penalize_rider',
                'penalize_seller',
            ])->nullable();
            $table->timestamps();

            $table->unique('order_id');
        });

        Schema::create('ratings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('order_id')->constrained('orders')->cascadeOnDelete();
            $table->foreignId('rater_user_id')->constrained('users');
            $table->foreignId('ratee_user_id')->constrained('users');
            $table->enum('ratee_type', ['seller', 'rider']);
            $table->unsignedTinyInteger('stars');
            $table->text('comment')->nullable();
            $table->timestamps();

            $table->unique(['order_id', 'rater_user_id', 'ratee_type']);
        });

        Schema::create('kyc_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users');
            $table->enum('kyc_type', ['buyer_basic', 'seller', 'rider']);
            $table->enum('status', ['pending', 'approved', 'rejected'])->default('pending');
            $table->timestamp('submitted_at');
            $table->foreignId('reviewed_by')->nullable()->constrained('users');
            $table->timestamp('reviewed_at')->nullable();
            $table->text('rejection_reason')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'kyc_type', 'status']);
        });

        Schema::create('kyc_documents', function (Blueprint $table) {
            $table->id();
            $table->foreignId('kyc_request_id')->constrained('kyc_requests')->cascadeOnDelete();
            $table->string('doc_type');
            $table->string('file_url');
            $table->timestamps();
        });

        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('actor_user_id')->nullable()->constrained('users');
            $table->string('action');
            $table->string('auditable_type')->nullable();
            $table->unsignedBigInteger('auditable_id')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->json('meta_json')->nullable();
            $table->timestamps();

            $table->index(['action', 'created_at']);
            $table->index(['auditable_type', 'auditable_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('kyc_documents');
        Schema::dropIfExists('kyc_requests');
        Schema::dropIfExists('ratings');
        Schema::dropIfExists('disputes');
        Schema::dropIfExists('order_evidence');
        Schema::dropIfExists('dispatch_offers');
        Schema::dropIfExists('dispatch_jobs');
        Schema::dropIfExists('payouts');
        Schema::dropIfExists('escrow_holds');
        Schema::dropIfExists('order_status_history');
        Schema::dropIfExists('order_items');
        Schema::dropIfExists('orders');
        Schema::dropIfExists('wallet_transactions');
        Schema::dropIfExists('wallet_accounts');
        Schema::dropIfExists('seller_rider_pools');
        Schema::dropIfExists('rider_availability');
        Schema::dropIfExists('rider_profiles');
        Schema::dropIfExists('product_images');
        Schema::dropIfExists('products');
        Schema::dropIfExists('seller_bank_accounts');
        Schema::dropIfExists('shops');
        Schema::dropIfExists('user_zones');
        Schema::dropIfExists('zones');
    }
};

```

```php
<?php

// database/migrations/2026_01_26_130000_add_meta_json_to_kyc_requests.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kyc_requests', function (Blueprint $table) {
            $table->json('meta_json')->nullable()->after('rejection_reason');
        });
    }

    public function down(): void
    {
        Schema::table('kyc_requests', function (Blueprint $table) {
            $table->dropColumn('meta_json');
        });
    }
};

```

```php
<?php

// database/seeders/DatabaseSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            ZonesSeeder::class,
            SampleUsersSeeder::class,
        ]);
    }
}
```

```php
<?php

// database/seeders/SampleUsersSeeder.php

namespace Database\Seeders;

use App\Domain\Dispatch\Models\SellerRiderPool;
use App\Domain\Products\Models\Product;
use App\Domain\Riders\Models\RiderAvailability;
use App\Domain\Riders\Models\RiderProfile;
use App\Domain\Shops\Models\SellerBankAccount;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SampleUsersSeeder extends Seeder
{
    public function run(): void
    {
        $zone = Zone::query()->first() ?? Zone::create([
            'name' => 'Yaba',
            'city' => 'Lagos',
            'state' => 'Lagos',
            'is_active' => true,
        ]);

        $admin = User::updateOrCreate(
            ['phone' => '08000000001'],
            [
                'full_name' => 'Smartlink Admin',
                'email' => 'admin@smartlink.test',
                'password' => Hash::make('password'),
                'role' => UserRole::Admin,
                'status' => UserStatus::Active,
                'phone_verified_at' => now(),
                'email_verified_at' => now(),
            ],
        );

        $buyer = User::updateOrCreate(
            ['phone' => '08000000002'],
            [
                'full_name' => 'Smartlink Buyer',
                'email' => 'buyer@smartlink.test',
                'password' => Hash::make('password'),
                'role' => UserRole::Buyer,
                'status' => UserStatus::Active,
                'phone_verified_at' => now(),
                'email_verified_at' => now(),
            ],
        );

        UserZone::updateOrCreate(
            ['user_id' => $buyer->id, 'type' => 'home'],
            ['zone_id' => $zone->id],
        );

        $seller = User::updateOrCreate(
            ['phone' => '08000000003'],
            [
                'full_name' => 'Smartlink Seller',
                'email' => 'seller@smartlink.test',
                'password' => Hash::make('password'),
                'role' => UserRole::Seller,
                'status' => UserStatus::Active,
                'phone_verified_at' => now(),
                'email_verified_at' => now(),
            ],
        );

        UserZone::updateOrCreate(
            ['user_id' => $seller->id, 'type' => 'operational'],
            ['zone_id' => $zone->id],
        );

        $shop = Shop::updateOrCreate(
            ['seller_user_id' => $seller->id],
            [
                'shop_name' => 'Smartlink Electronics',
                'description' => 'Verified local electronics shop',
                'zone_id' => $zone->id,
                'address_text' => '1 Market Street',
                'is_verified' => true,
                'verification_phase' => 'phase1',
            ],
        );

        SellerBankAccount::updateOrCreate(
            ['seller_user_id' => $seller->id],
            [
                'bank_name' => 'Demo Bank',
                'account_number' => '0000000000',
                'account_name' => 'Smartlink Seller',
                'verified_at' => now(),
            ],
        );

        $rider = User::updateOrCreate(
            ['phone' => '08000000004'],
            [
                'full_name' => 'Smartlink Rider',
                'email' => 'rider@smartlink.test',
                'password' => Hash::make('password'),
                'role' => UserRole::Rider,
                'status' => UserStatus::Active,
                'phone_verified_at' => now(),
                'email_verified_at' => now(),
            ],
        );

        UserZone::updateOrCreate(
            ['user_id' => $rider->id, 'type' => 'operational'],
            ['zone_id' => $zone->id],
        );

        RiderProfile::updateOrCreate(
            ['rider_user_id' => $rider->id],
            [
                'vehicle_type' => 'bike',
                'plate_number' => null,
                'is_elite' => true,
                'qr_code_token' => Str::uuid()->toString(),
            ],
        );

        RiderAvailability::updateOrCreate(
            ['rider_user_id' => $rider->id],
            ['status' => 'available', 'last_seen_at' => now()],
        );

        SellerRiderPool::updateOrCreate(
            ['shop_id' => $shop->id, 'rider_user_id' => $rider->id],
            ['status' => 'active', 'added_by' => $seller->id],
        );

        Product::updateOrCreate(
            ['shop_id' => $shop->id, 'name' => 'USB-C Charger'],
            [
                'description' => 'Fast charging adapter',
                'price' => 5000,
                'currency' => 'NGN',
                'stock_qty' => 50,
                'status' => 'active',
            ],
        );

        /** @var WalletService $walletService */
        $walletService = app(WalletService::class);
        $buyerWallet = $walletService->walletFor($buyer);

        $walletService->record(
            $buyerWallet,
            WalletTransactionType::Topup,
            WalletTransactionDirection::In,
            100000,
            'seed:buyer:topup',
            relatedEntityType: 'seeders',
            relatedEntityId: null,
            meta: ['actor_user_id' => $admin->id],
        );
    }
}
```

```php
<?php

// database/seeders/ZonesSeeder.php

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
                ['is_active' => true],
            );
        }
    }
}

```

```xml
<!-- phpunit.xml -->
<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="vendor/phpunit/phpunit/phpunit.xsd"
         bootstrap="vendor/autoload.php"
         colors="true"
>
    <testsuites>
        <testsuite name="Unit">
            <directory>tests/Unit</directory>
        </testsuite>
        <testsuite name="Feature">
            <directory>tests/Feature</directory>
        </testsuite>
    </testsuites>
    <source>
        <include>
            <directory>app</directory>
        </include>
    </source>
    <php>
        <env name="APP_ENV" value="testing"/>
        <env name="APP_MAINTENANCE_DRIVER" value="file"/>
        <env name="BCRYPT_ROUNDS" value="4"/>
        <env name="CACHE_STORE" value="array"/>
        <env name="DB_CONNECTION" value="sqlite"/>
        <env name="DB_DATABASE" value=":memory:"/>
        <env name="MAIL_MAILER" value="array"/>
        <env name="PULSE_ENABLED" value="false"/>
        <env name="QUEUE_CONNECTION" value="sync"/>
        <env name="SESSION_DRIVER" value="array"/>
        <env name="TELESCOPE_ENABLED" value="false"/>
    </php>
</phpunit>

```

```json
// postman/Smartlink.postman_collection.json
{
  "info": {
    "name": "Smartlink API (MVP)",
    "_postman_id": "b7d2a6b1-5c3f-4f40-9e70-6d0c3d3e9c1a",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Auth - Register",
      "request": {
        "method": "POST",
        "header": [{ "key": "Content-Type", "value": "application/json" }],
        "url": { "raw": "{{base_url}}/api/auth/register", "host": ["{{base_url}}"], "path": ["api", "auth", "register"] },
        "body": {
          "mode": "raw",
          "raw": "{\n  \"full_name\": \"Buyer One\",\n  \"phone\": \"08012345678\",\n  \"email\": \"buyer1@example.com\",\n  \"password\": \"password\",\n  \"role\": \"buyer\",\n  \"device_name\": \"postman\"\n}\n"
        }
      }
    },
    {
      "name": "Auth - Login",
      "request": {
        "method": "POST",
        "header": [{ "key": "Content-Type", "value": "application/json" }],
        "url": { "raw": "{{base_url}}/api/auth/login", "host": ["{{base_url}}"], "path": ["api", "auth", "login"] },
        "body": { "mode": "raw", "raw": "{\n  \"phone\": \"08012345678\",\n  \"password\": \"password\",\n  \"device_name\": \"postman\"\n}\n" }
      }
    },
    {
      "name": "Zones - List",
      "request": {
        "method": "GET",
        "url": { "raw": "{{base_url}}/api/zones", "host": ["{{base_url}}"], "path": ["api", "zones"] }
      }
    },
    {
      "name": "Wallet - Show (auth)",
      "request": {
        "method": "GET",
        "header": [{ "key": "Authorization", "value": "Bearer {{token}}" }],
        "url": { "raw": "{{base_url}}/api/wallet", "host": ["{{base_url}}"], "path": ["api", "wallet"] }
      }
    },
    {
      "name": "Orders - Create (auth)",
      "request": {
        "method": "POST",
        "header": [
          { "key": "Content-Type", "value": "application/json" },
          { "key": "Authorization", "value": "Bearer {{token}}" }
        ],
        "url": { "raw": "{{base_url}}/api/orders", "host": ["{{base_url}}"], "path": ["api", "orders"] },
        "body": {
          "mode": "raw",
          "raw": "{\n  \"shop_id\": 1,\n  \"delivery_address_text\": \"1 Market Street\",\n  \"items\": [\n    { \"product_id\": 1, \"qty\": 1 }\n  ]\n}\n"
        }
      }
    }
  ],
  "variable": [
    { "key": "base_url", "value": "http://127.0.0.1:8000" },
    { "key": "token", "value": "" }
  ]
}


```

```php
<?php

// routes/api.php

use App\Domain\Auth\Controllers\AuthController;
use App\Domain\Auth\Controllers\OtpController;
use App\Domain\Disputes\Controllers\AdminDisputeController;
use App\Domain\Kyc\Controllers\AdminKycController;
use App\Domain\Kyc\Controllers\KycController;
use App\Domain\Orders\Controllers\OrderController;
use App\Domain\Ratings\Controllers\RatingController;
use App\Domain\Shops\Controllers\PublicShopController;
use App\Domain\Shops\Controllers\SellerShopController;
use App\Domain\Users\Controllers\UserZoneController;
use App\Domain\Wallet\Controllers\WalletController;
use App\Domain\Webhooks\Controllers\PaystackWebhookController;
use App\Domain\Products\Controllers\PublicProductController;
use App\Domain\Products\Controllers\SellerProductController;
use App\Domain\Dispatch\Controllers\RiderDispatchController;
use App\Domain\Dispatch\Controllers\SellerDispatchController;
use App\Domain\Dispatch\Controllers\RiderOrderFlowController;
use App\Domain\Zones\Controllers\ZoneController;
use Illuminate\Support\Facades\Route;

$registerRoutes = function (): void {
    Route::prefix('auth')->group(function (): void {
        Route::post('register', [AuthController::class, 'register'])->middleware('throttle:auth');
        Route::post('login', [AuthController::class, 'login'])->middleware('throttle:auth');

        Route::post('otp/send', [OtpController::class, 'send'])->middleware('throttle:otp');
        Route::post('otp/verify', [OtpController::class, 'verify'])->middleware('throttle:otp');

        Route::middleware('auth:sanctum')->group(function (): void {
            Route::post('logout', [AuthController::class, 'logout']);
        });
    });

    Route::post('webhooks/paystack', [PaystackWebhookController::class, 'handle']);

    Route::get('zones', [ZoneController::class, 'index']);
    Route::get('shops', [PublicShopController::class, 'index']);
    Route::get('shops/{shop}', [PublicShopController::class, 'show']);
    Route::get('products', [PublicProductController::class, 'index']);
    Route::get('products/{product}', [PublicProductController::class, 'show']);

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::get('me', [AuthController::class, 'me']);

        Route::post('user/zones', [UserZoneController::class, 'store']);

        Route::post('kyc/submit', [KycController::class, 'submit']);
        Route::get('kyc/status', [KycController::class, 'status']);

        Route::get('wallet', [WalletController::class, 'show']);
        Route::get('wallet/transactions', [WalletController::class, 'transactions']);
        Route::post('wallet/topup/initiate', [WalletController::class, 'initiateTopup']);

        Route::post('orders', [OrderController::class, 'store']);
        Route::get('orders', [OrderController::class, 'index']);
        Route::get('orders/{order}', [OrderController::class, 'show']);
        Route::post('orders/{order}/confirm-delivery', [OrderController::class, 'confirmDelivery']);
        Route::post('orders/{order}/raise-dispute', [OrderController::class, 'raiseDispute']);

        Route::post('ratings', [RatingController::class, 'store']);

        Route::middleware('role:seller')->group(function (): void {
            Route::prefix('seller')->group(function (): void {
                Route::post('shop', [SellerShopController::class, 'store']);
                Route::get('orders', [SellerDispatchController::class, 'orders']);

                Route::post('products', [SellerProductController::class, 'store']);
                Route::patch('products/{product}', [SellerProductController::class, 'update']);

                Route::post('rider-pool/add', [SellerDispatchController::class, 'addRiderToPool']);
                Route::post('rider-pool/remove', [SellerDispatchController::class, 'removeRiderFromPool']);
            });

            Route::post('orders/{order}/dispatch', [SellerDispatchController::class, 'dispatch']);
        });

        Route::middleware('role:rider')->prefix('rider')->group(function (): void {
            Route::get('dispatch/offers', [RiderDispatchController::class, 'offers']);
            Route::post('dispatch/offers/{offerId}/accept', [RiderDispatchController::class, 'accept']);
            Route::post('dispatch/offers/{offerId}/decline', [RiderDispatchController::class, 'decline']);

            Route::post('orders/{order}/pickup-proof', [RiderOrderFlowController::class, 'uploadPickupProof']);
            Route::post('orders/{order}/mark-picked-up', [RiderOrderFlowController::class, 'markPickedUp']);
            Route::post('orders/{order}/mark-delivered', [RiderOrderFlowController::class, 'markDelivered']);
        });

        Route::middleware('role:admin')->prefix('admin')->group(function (): void {
            Route::post('kyc/requests/{kycRequest}/approve', [AdminKycController::class, 'approve']);
            Route::post('kyc/requests/{kycRequest}/reject', [AdminKycController::class, 'reject']);
            Route::post('disputes/{order}/resolve', [AdminDisputeController::class, 'resolve']);
        });
    });
};

Route::prefix('v1')->group($registerRoutes);
Route::group([], $registerRoutes);

```

```php
<?php

// routes/web.php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'name' => 'Smartlink API',
        'status' => 'ok',
    ]);
});
```

```php
<?php

// tests/Feature/ConfirmDeliveryReleasesEscrowTest.php

namespace Tests\Feature;

use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Products\Models\Product;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ConfirmDeliveryReleasesEscrowTest extends TestCase
{
    use RefreshDatabase;

    public function test_confirm_delivery_releases_escrow_and_credits_seller(): void
    {
        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
        ]);

        $buyer = User::create([
            'full_name' => 'Buyer',
            'phone' => '08088888888',
            'email' => 'buyer4@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $buyer->id, 'zone_id' => $zone->id, 'type' => 'home']);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08099999999',
            'email' => 'seller4@test.local',
            'password' => 'password',
            'role' => UserRole::Seller,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $seller->id, 'zone_id' => $zone->id, 'type' => 'operational']);

        $shop = Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
        ]);

        $product = Product::create([
            'shop_id' => $shop->id,
            'name' => 'Item',
            'description' => null,
            'price' => 1500,
            'currency' => 'NGN',
            'stock_qty' => 10,
            'status' => 'active',
        ]);

        /** @var WalletService $walletService */
        $walletService = app(WalletService::class);
        $buyerWallet = $walletService->walletFor($buyer);
        $walletService->record(
            $buyerWallet,
            WalletTransactionType::Topup,
            WalletTransactionDirection::In,
            5000,
            'test:topup2',
            meta: ['actor_user_id' => $buyer->id],
        );

        Sanctum::actingAs($buyer);

        $orderResp = $this->postJson('/api/orders', [
            'shop_id' => $shop->id,
            'delivery_address_text' => 'Buyer Address',
            'items' => [
                ['product_id' => $product->id, 'qty' => 2],
            ],
        ])->assertOk();

        $orderId = (int) $orderResp->json('data.id');

        $order = Order::query()->whereKey($orderId)->firstOrFail();
        $order->forceFill(['status' => OrderStatus::Delivered])->save();

        $confirmResp = $this->postJson("/api/orders/{$orderId}/confirm-delivery");
        $confirmResp->assertOk();

        $this->assertDatabaseHas('escrow_holds', [
            'order_id' => $orderId,
            'status' => 'released',
        ]);

        $sellerWallet = $walletService->walletFor($seller);
        $sellerWallet->refresh();
        $this->assertSame('3000.00', (string) $sellerWallet->available_balance);

        $this->assertDatabaseHas('wallet_transactions', [
            'reference' => "escrow:order:{$orderId}:release",
            'type' => 'release',
            'direction' => 'in',
        ]);

        $this->assertDatabaseHas('payouts', [
            'order_id' => $orderId,
            'status' => 'pending',
        ]);
    }
}

```

```php
<?php

// tests/Feature/DispatchAcceptTest.php

namespace Tests\Feature;

use App\Domain\Dispatch\Models\DispatchJob;
use App\Domain\Dispatch\Models\DispatchOffer;
use App\Domain\Orders\Models\Order;
use App\Domain\Products\Models\Product;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DispatchAcceptTest extends TestCase
{
    use RefreshDatabase;

    public function test_first_rider_accept_wins_and_expires_others(): void
    {
        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
        ]);

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08044444444',
            'email' => 'seller2@test.local',
            'password' => 'password',
            'role' => UserRole::Seller,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $seller->id, 'zone_id' => $zone->id, 'type' => 'operational']);

        $shop = Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
        ]);

        $buyer = User::create([
            'full_name' => 'Buyer',
            'phone' => '08055555555',
            'email' => 'buyer3@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $buyer->id, 'zone_id' => $zone->id, 'type' => 'home']);

        $order = Order::create([
            'buyer_user_id' => $buyer->id,
            'shop_id' => $shop->id,
            'zone_id' => $zone->id,
            'subtotal_amount' => 1000,
            'delivery_fee_amount' => 0,
            'total_amount' => 1000,
            'status' => 'dispatching',
            'payment_status' => 'paid',
            'delivery_address_text' => 'Addr',
        ]);

        $rider1 = User::create([
            'full_name' => 'Rider 1',
            'phone' => '08066666666',
            'email' => 'rider1@test.local',
            'password' => 'password',
            'role' => UserRole::Rider,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        $rider2 = User::create([
            'full_name' => 'Rider 2',
            'phone' => '08077777777',
            'email' => 'rider2@test.local',
            'password' => 'password',
            'role' => UserRole::Rider,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $rider1->id, 'zone_id' => $zone->id, 'type' => 'operational']);
        UserZone::create(['user_id' => $rider2->id, 'zone_id' => $zone->id, 'type' => 'operational']);

        \App\Domain\Riders\Models\RiderAvailability::create(['rider_user_id' => $rider1->id, 'status' => 'available', 'last_seen_at' => now()]);
        \App\Domain\Riders\Models\RiderAvailability::create(['rider_user_id' => $rider2->id, 'status' => 'available', 'last_seen_at' => now()]);

        $job = DispatchJob::create([
            'order_id' => $order->id,
            'shop_id' => $shop->id,
            'zone_id' => $zone->id,
            'status' => 'broadcasting',
            'assigned_rider_user_id' => null,
            'private_pool_only_until' => now()->addMinutes(10),
            'fallback_broadcast_at' => now()->addMinutes(10),
        ]);

        $offer1 = DispatchOffer::create([
            'dispatch_job_id' => $job->id,
            'rider_user_id' => $rider1->id,
            'offer_status' => 'sent',
            'offered_at' => now(),
        ]);

        $offer2 = DispatchOffer::create([
            'dispatch_job_id' => $job->id,
            'rider_user_id' => $rider2->id,
            'offer_status' => 'sent',
            'offered_at' => now(),
        ]);

        Sanctum::actingAs($rider1);
        $resp1 = $this->postJson("/api/rider/dispatch/offers/{$offer1->id}/accept");
        $resp1->assertOk();

        $job->refresh();
        $this->assertSame($rider1->id, $job->assigned_rider_user_id);

        Sanctum::actingAs($rider2);
        $resp2 = $this->postJson("/api/rider/dispatch/offers/{$offer2->id}/accept");
        $resp2->assertStatus(409);

        $offer2->refresh();
        $this->assertSame('expired', $offer2->offer_status->value);
    }
}

```

```php
<?php

// tests/Feature/ExampleTest.php

namespace Tests\Feature;

// use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_the_application_returns_a_successful_response(): void
    {
        $response = $this->get('/');

        $response->assertStatus(200);
    }
}
```

```php
<?php

// tests/Feature/OrderPlacementTest.php

namespace Tests\Feature;

use App\Domain\Orders\Enums\OrderStatus;
use App\Domain\Orders\Models\Order;
use App\Domain\Products\Models\Product;
use App\Domain\Shops\Models\Shop;
use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Enums\WalletTransactionDirection;
use App\Domain\Wallet\Enums\WalletTransactionType;
use App\Domain\Wallet\Services\WalletService;
use App\Domain\Zones\Models\UserZone;
use App\Domain\Zones\Models\Zone;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class OrderPlacementTest extends TestCase
{
    use RefreshDatabase;

    public function test_order_creation_holds_escrow(): void
    {
        $zone = Zone::create([
            'name' => 'Test Zone',
            'city' => 'Test City',
            'state' => 'Test State',
            'is_active' => true,
        ]);

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

        $seller = User::create([
            'full_name' => 'Seller',
            'phone' => '08022222222',
            'email' => 'seller@test.local',
            'password' => 'password',
            'role' => UserRole::Seller,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        UserZone::create(['user_id' => $seller->id, 'zone_id' => $zone->id, 'type' => 'operational']);

        $shop = Shop::create([
            'seller_user_id' => $seller->id,
            'shop_name' => 'Shop',
            'description' => null,
            'zone_id' => $zone->id,
            'address_text' => 'Addr',
            'is_verified' => true,
            'verification_phase' => 'phase1',
        ]);

        $product = Product::create([
            'shop_id' => $shop->id,
            'name' => 'Item',
            'description' => null,
            'price' => 1000,
            'currency' => 'NGN',
            'stock_qty' => 10,
            'status' => 'active',
        ]);

        /** @var WalletService $walletService */
        $walletService = app(WalletService::class);
        $buyerWallet = $walletService->walletFor($buyer);
        $walletService->record(
            $buyerWallet,
            WalletTransactionType::Topup,
            WalletTransactionDirection::In,
            5000,
            'test:topup',
            meta: ['actor_user_id' => $buyer->id],
        );

        Sanctum::actingAs($buyer);

        $response = $this->postJson('/api/orders', [
            'shop_id' => $shop->id,
            'delivery_address_text' => 'Buyer Address',
            'items' => [
                ['product_id' => $product->id, 'qty' => 2],
            ],
        ]);

        $response->assertOk();
        $orderId = (int) $response->json('data.id');

        $this->assertDatabaseHas('orders', [
            'id' => $orderId,
            'status' => OrderStatus::Paid->value,
            'payment_status' => 'paid',
        ]);

        $this->assertDatabaseHas('escrow_holds', [
            'order_id' => $orderId,
            'status' => 'held',
        ]);

        $this->assertDatabaseHas('wallet_transactions', [
            'reference' => "order:{$orderId}:hold",
            'type' => 'hold',
            'direction' => 'out',
        ]);

        $buyerWallet->refresh();
        $this->assertSame('3000.00', (string) $buyerWallet->available_balance);
    }
}

```

```php
<?php

// tests/Feature/PaystackWebhookTest.php

namespace Tests\Feature;

use App\Domain\Users\Enums\UserRole;
use App\Domain\Users\Enums\UserStatus;
use App\Domain\Users\Models\User;
use App\Domain\Wallet\Services\WalletService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PaystackWebhookTest extends TestCase
{
    use RefreshDatabase;

    public function test_webhook_credits_wallet_idempotently(): void
    {
        config(['smartlink.paystack.webhook_secret' => 'test_secret']);

        $user = User::create([
            'full_name' => 'Buyer',
            'phone' => '08033333333',
            'email' => 'buyer2@test.local',
            'password' => 'password',
            'role' => UserRole::Buyer,
            'status' => UserStatus::Active,
            'phone_verified_at' => now(),
        ]);

        /** @var WalletService $walletService */
        $walletService = app(WalletService::class);
        $wallet = $walletService->walletFor($user);

        $payload = [
            'event' => 'charge.success',
            'data' => [
                'id' => 12345,
                'status' => 'success',
                'reference' => 'paystack_ref_123',
                'amount' => 50000,
                'channel' => 'card',
                'paid_at' => now()->toISOString(),
                'metadata' => [
                    'user_id' => $user->id,
                    'purpose' => 'wallet_topup',
                ],
            ],
        ];

        $raw = json_encode($payload);
        $signature = hash_hmac('sha512', $raw, 'test_secret');

        $resp1 = $this
            ->withHeader('x-paystack-signature', $signature)
            ->postJson('/api/webhooks/paystack', $payload);

        $resp1->assertOk();

        $wallet->refresh();
        $this->assertSame('500.00', (string) $wallet->available_balance);

        // Duplicate webhook should be ignored (unique reference).
        $resp2 = $this
            ->withHeader('x-paystack-signature', $signature)
            ->postJson('/api/webhooks/paystack', $payload);

        $resp2->assertOk();

        $wallet->refresh();
        $this->assertSame('500.00', (string) $wallet->available_balance);

        $this->assertDatabaseCount('wallet_transactions', 1);
    }
}
```

```php
<?php

// tests/TestCase.php

namespace Tests;

use Illuminate\Foundation\Testing\TestCase as BaseTestCase;

abstract class TestCase extends BaseTestCase
{
    //
}
```

```php
<?php

// tests/Unit/ExampleTest.php

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

class ExampleTest extends TestCase
{
    /**
     * A basic test example.
     */
    public function test_that_true_is_true(): void
    {
        $this->assertTrue(true);
    }
}
```
