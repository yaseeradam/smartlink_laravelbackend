<?php

use App\Domain\Auth\Controllers\AuthController;
use App\Domain\Auth\Controllers\OtpController;
use App\Domain\Disputes\Controllers\AdminDisputeController;
use App\Domain\Kyc\Controllers\AdminKycController;
use App\Domain\Kyc\Controllers\KycController;
use App\Domain\Orders\Controllers\OrderController;
use App\Domain\Orders\Controllers\OrderQuoteController;
use App\Domain\Orders\Controllers\ServiceOrderController;
use App\Domain\Orders\Controllers\SellerOrderWorkflowController;
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
use App\Domain\Delivery\Controllers\AdminDeliveryPricingRuleController;
use App\Domain\Escrow\Controllers\AdminPayoutController;
use App\Domain\Fraud\Controllers\AdminBlockedEntityController;
use App\Domain\Messaging\Controllers\MessageController;
use App\Domain\Zones\Controllers\ZoneController;
use App\Domain\Zones\Controllers\AdminZoneController;
use App\Domain\Returns\Controllers\ReturnController;
use App\Domain\Returns\Controllers\AdminReturnController;
use App\Domain\Shops\Controllers\SellerMetricsController;
use App\Domain\Users\Controllers\UserDeviceController;
use App\Domain\Workflows\Controllers\AdminWorkflowController;
use App\Domain\Workflows\Controllers\AdminWorkflowStepController;
use App\Domain\Workflows\Controllers\AdminWorkflowTransitionController;
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
        Route::post('user/devices', [UserDeviceController::class, 'store']);

        Route::post('kyc/submit', [KycController::class, 'submit']);
        Route::get('kyc/status', [KycController::class, 'status']);

        Route::get('wallet', [WalletController::class, 'show']);
        Route::get('wallet/transactions', [WalletController::class, 'transactions']);
        Route::post('wallet/topup/initiate', [WalletController::class, 'initiateTopup']);

        Route::post('orders', [OrderController::class, 'store']);
        Route::post('orders/service', [ServiceOrderController::class, 'store']);
        Route::get('orders', [OrderController::class, 'index']);
        Route::get('orders/{order}', [OrderController::class, 'show']);
        Route::post('orders/{order}/confirm-delivery', [OrderController::class, 'confirmDelivery']);
        Route::post('orders/{order}/raise-dispute', [OrderController::class, 'raiseDispute']);
        Route::post('orders/{order}/quote/approve', [OrderQuoteController::class, 'approve']);
        Route::post('orders/{order}/quote/reject', [OrderQuoteController::class, 'reject']);
        Route::post('orders/{order}/cancel', [OrderController::class, 'cancel']);
        Route::post('orders/{order}/returns', [ReturnController::class, 'store']);
        Route::get('orders/{order}/messages', [MessageController::class, 'index']);
        Route::post('orders/{order}/messages', [MessageController::class, 'store']);

        Route::post('ratings', [RatingController::class, 'store']);

        Route::middleware('role:seller')->group(function (): void {
            Route::prefix('seller')->group(function (): void {
                Route::post('shop', [SellerShopController::class, 'store']);
                Route::get('shops', [SellerShopController::class, 'index']);
                Route::get('shops/{shop}', [SellerShopController::class, 'show']);
                Route::post('shops/{shop}/default-workflow', [SellerShopController::class, 'setDefaultWorkflow']);
                Route::get('orders', [SellerDispatchController::class, 'orders']);
                Route::get('metrics', [SellerMetricsController::class, 'show']);

                Route::post('products', [SellerProductController::class, 'store']);
                Route::patch('products/{product}', [SellerProductController::class, 'update']);

                Route::post('orders/{order}/workflow/start', [SellerOrderWorkflowController::class, 'start']);
                Route::post('orders/{order}/workflow/advance', [SellerOrderWorkflowController::class, 'advance']);
                Route::get('orders/{order}/workflow/next-steps', [SellerOrderWorkflowController::class, 'nextSteps']);
                Route::post('orders/{order}/quote/send', [OrderQuoteController::class, 'send']);

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
            Route::post('orders/{order}/delivery-proof', [RiderOrderFlowController::class, 'uploadDeliveryProof']);
            Route::post('orders/{order}/mark-picked-up', [RiderOrderFlowController::class, 'markPickedUp']);
            Route::post('orders/{order}/mark-delivered', [RiderOrderFlowController::class, 'markDelivered']);
        });

        Route::middleware('role:admin')->prefix('admin')->group(function (): void {
            Route::post('kyc/requests/{kycRequest}/approve', [AdminKycController::class, 'approve']);
            Route::post('kyc/requests/{kycRequest}/reject', [AdminKycController::class, 'reject']);
            Route::post('disputes/{order}/resolve', [AdminDisputeController::class, 'resolve']);
            Route::post('zones/{zone}/pause', [AdminZoneController::class, 'pause']);
            Route::post('zones/{zone}/resume', [AdminZoneController::class, 'resume']);
            Route::get('delivery-pricing-rules', [AdminDeliveryPricingRuleController::class, 'index']);
            Route::post('delivery-pricing-rules', [AdminDeliveryPricingRuleController::class, 'store']);
            Route::get('blocked-entities', [AdminBlockedEntityController::class, 'index']);
            Route::post('blocked-entities', [AdminBlockedEntityController::class, 'store']);
            Route::post('payouts/trigger', [AdminPayoutController::class, 'trigger']);
            Route::post('returns/{returnRequest}/approve', [AdminReturnController::class, 'approve']);
            Route::post('returns/{returnRequest}/reject', [AdminReturnController::class, 'reject']);
            Route::post('returns/{returnRequest}/complete', [AdminReturnController::class, 'complete']);

            Route::get('workflows', [AdminWorkflowController::class, 'index']);
            Route::post('workflows', [AdminWorkflowController::class, 'store']);
            Route::get('workflows/{workflow}', [AdminWorkflowController::class, 'show']);
            Route::patch('workflows/{workflow}', [AdminWorkflowController::class, 'update']);

            Route::post('workflows/{workflow}/steps', [AdminWorkflowStepController::class, 'store']);
            Route::patch('workflow-steps/{workflowStep}', [AdminWorkflowStepController::class, 'update']);
            Route::delete('workflow-steps/{workflowStep}', [AdminWorkflowStepController::class, 'destroy']);

            Route::post('workflows/{workflow}/transitions', [AdminWorkflowTransitionController::class, 'store']);
            Route::delete('workflows/{workflow}/transitions', [AdminWorkflowTransitionController::class, 'destroy']);
        });
    });
};

Route::prefix('v1')->group($registerRoutes);
Route::group([], $registerRoutes);
