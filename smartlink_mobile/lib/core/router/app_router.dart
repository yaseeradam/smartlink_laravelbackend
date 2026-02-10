import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/home/home_gate_screen.dart';
import '../../screens/auth/auth_screen.dart';
import '../../screens/auth/otp_verify_screen.dart';
import '../../screens/shop/shop_detail_screen.dart';
import '../../screens/product/product_detail_screen.dart';
import '../../screens/cart/cart_screen.dart';
import '../../screens/checkout/checkout_screen.dart';
import '../../screens/orders/orders_screen.dart';
import '../../screens/orders/order_tracking_screen.dart';
import '../../screens/wallet/wallet_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/zones/zone_picker_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/addresses/address_list_screen.dart';
import '../../screens/kyc/kyc_status_screen.dart';
import '../../screens/services/services_home_screen.dart';
import '../../screens/security/security_screen.dart';
import '../../screens/feed/feed_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/messages/messages_screen.dart';
import '../../screens/disputes/disputes_screen.dart';
import '../../screens/returns/returns_screen.dart';
import '../../screens/categories/categories_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/notifications/notification_settings_screen.dart';
import '../../screens/referrals/referrals_screen.dart';
import '../../screens/search/search_filters_screen.dart';
import '../../screens/trust/trust_center_screen.dart';
import '../../screens/trust/trust_score_screen.dart';
import '../../screens/trust/trust_analysis_screen.dart';
import '../../screens/trust/trust_perks_screen.dart';
import '../../screens/trust/trust_network_screen.dart';
import '../../screens/wallet/wallet_transactions_screen.dart';
import '../../screens/wallet/wallet_transaction_detail_screen.dart';
import '../../screens/wallet/wallet_card_screen.dart';
import '../../screens/wallet/wallet_card_customize_screen.dart';
import '../../screens/wallet/wallet_card_upgrade_screen.dart';
import '../../screens/orders/order_messages_screen.dart';
import '../../screens/disputes/dispute_messages_screen.dart';
import '../../screens/merchant/my_shop_screen.dart';
import '../../screens/merchant/my_products_screen.dart';
import '../../screens/merchant/earnings_screen.dart';
import '../../screens/merchant/seller_orders_screen.dart';
import '../../screens/merchant/seller_order_detail_screen.dart';
import '../../screens/merchant/seller_categories_screen.dart';
import '../../screens/merchant/seller_bank_account_screen.dart';
import '../../screens/merchant/seller_withdrawals_screen.dart';
import '../../screens/merchant/seller_metrics_screen.dart';
import '../../screens/merchant/seller_earnings_analytics_screen.dart';
import '../../screens/merchant/seller_escrow_holds_screen.dart';
import '../../screens/merchant/merchant_services_screen.dart';
import '../../screens/merchant/merchant_coverage_areas_screen.dart';
import '../../screens/merchant/merchant_service_requests_screen.dart';
import '../../screens/merchant/merchant_service_request_detail_screen.dart';
import '../../screens/rider/dispatch_offers_screen.dart';
import '../../screens/rider/availability_screen.dart';
import '../../screens/rider/stats_screen.dart';
import '../../screens/rider/rider_orders_screen.dart';
import '../../screens/rider/rider_order_detail_screen.dart';
import '../../screens/rider/rider_profile_screen.dart';

class AppRouter {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerify = '/otp-verify';
  static const String home = '/home';
  static const String shopDetail = '/shop-detail';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderTracking = '/order-tracking';
  static const String wallet = '/wallet';
  static const String profile = '/profile';
  static const String zones = '/zones';
  static const String search = '/search';
  static const String addresses = '/addresses';
  static const String kyc = '/kyc';
  static const String services = '/services';
  static const String security = '/security';
  static const String feed = '/feed';
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notifications/settings';
  static const String messages = '/messages';
  static const String disputes = '/disputes';
  static const String disputeMessages = '/disputes/messages';
  static const String returns = '/returns';
  static const String categories = '/categories';
  static const String favorites = '/favorites';
  static const String searchFilters = '/search/filters';
  static const String trustCenter = '/trust';
  static const String trustScore = '/trust/score';
  static const String trustAnalysis = '/trust/analysis';
  static const String trustPerks = '/trust/perks';
  static const String trustNetwork = '/trust/network';
  static const String referrals = '/referrals';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletTransaction = '/wallet/transactions/detail';
  static const String walletCard = '/wallet/card';
  static const String walletCardCustomize = '/wallet/card/customize';
  static const String walletCardUpgrade = '/wallet/card/upgrade';
  static const String orderMessages = '/orders/messages';
  static const String merchantShop = '/merchant/shop';
  static const String merchantProducts = '/merchant/products';
  static const String merchantEarnings = '/merchant/earnings';
  static const String sellerOrders = '/seller/orders';
  static const String sellerOrderDetail = '/seller/orders/detail';
  static const String sellerCategories = '/seller/categories';
  static const String sellerBankAccount = '/seller/bank-account';
  static const String sellerWithdrawals = '/seller/withdrawals';
  static const String sellerMetrics = '/seller/metrics';
  static const String sellerEarningsAnalytics = '/seller/earnings/analytics';
  static const String sellerEscrowHolds = '/seller/escrow/holds';
  static const String merchantServicesManage = '/merchant/services/manage';
  static const String merchantCoverageAreas = '/merchant/coverage-areas';
  static const String merchantServiceRequestsManage =
      '/merchant/service-requests/manage';
  static const String merchantServiceRequestDetail =
      '/merchant/service-requests/detail';
  static const String riderDispatchOffers = '/rider/dispatch/offers';
  static const String riderAvailability = '/rider/availability';
  static const String riderStats = '/rider/stats';
  static const String riderOrders = '/rider/orders';
  static const String riderOrderDetail = '/rider/orders/detail';
  static const String riderProfile = '/rider/profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case auth:
      case login:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case otpVerify:
        final args = settings.arguments;
        if (args is OtpVerifyArgs) {
          return MaterialPageRoute(builder: (_) => OtpVerifyScreen(args: args));
        }
        return _errorRoute('Missing OTP args');
      case home:
        return MaterialPageRoute(builder: (_) => const HomeGateScreen());
      case shopDetail:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
              builder: (_) => ShopDetailScreen(shop: args));
        }
        return _errorRoute('Missing shop args');
      case productDetail:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: args));
        }
        return _errorRoute('Missing product args');
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case orders:
        return MaterialPageRoute(builder: (_) => const OrdersScreen());
      case orderTracking:
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute(
              builder: (_) => OrderTrackingScreen(orderId: args));
        }
        return _errorRoute('Missing order id');
      case wallet:
        return MaterialPageRoute(builder: (_) => const WalletScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case zones:
        final args = settings.arguments;
        if (args is ZonePickerArgs) {
          return MaterialPageRoute(
              builder: (_) => ZonePickerScreen(mode: args.mode));
        }
        return MaterialPageRoute(builder: (_) => const ZonePickerScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case addresses:
        final args = settings.arguments;
        if (args is AddressListArgs) {
          return MaterialPageRoute(
            builder: (_) =>
                AddressListScreen(selectionMode: args.selectionMode),
          );
        }
        return MaterialPageRoute(builder: (_) => const AddressListScreen());
      case kyc:
        return MaterialPageRoute(builder: (_) => const KycStatusScreen());
      case services:
        return MaterialPageRoute(builder: (_) => const ServicesHomeScreen());
      case security:
        return MaterialPageRoute(builder: (_) => const SecurityScreen());
      case feed:
        return MaterialPageRoute(builder: (_) => const FeedScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case notificationSettings:
        return MaterialPageRoute(
            builder: (_) => const NotificationSettingsScreen());
      case messages:
        return MaterialPageRoute(builder: (_) => const MessagesScreen());
      case disputes:
        return MaterialPageRoute(builder: (_) => const DisputesScreen());
      case disputeMessages:
        final args = settings.arguments;
        if (args != null) {
          return MaterialPageRoute(
              builder: (_) => DisputeMessagesScreen(disputeId: args));
        }
        return _errorRoute('Missing dispute id');
      case returns:
        return MaterialPageRoute(builder: (_) => const ReturnsScreen());
      case categories:
        return MaterialPageRoute(builder: (_) => const CategoriesScreen());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case searchFilters:
        return MaterialPageRoute(builder: (_) => const SearchFiltersScreen());
      case trustCenter:
        return MaterialPageRoute(builder: (_) => const TrustCenterScreen());
      case trustScore:
        return MaterialPageRoute(builder: (_) => const TrustScoreScreen());
      case trustAnalysis:
        return MaterialPageRoute(builder: (_) => const TrustAnalysisScreen());
      case trustPerks:
        return MaterialPageRoute(builder: (_) => const TrustPerksScreen());
      case trustNetwork:
        return MaterialPageRoute(builder: (_) => const TrustNetworkScreen());
      case referrals:
        return MaterialPageRoute(builder: (_) => const ReferralsScreen());
      case walletTransactions:
        return MaterialPageRoute(builder: (_) => const WalletTransactionsScreen());
      case walletTransaction:
        final args = settings.arguments;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => WalletTransactionDetailScreen(transactionId: args),
          );
        }
        return _errorRoute('Missing transaction id');
      case walletCard:
        return MaterialPageRoute(builder: (_) => const WalletCardScreen());
      case walletCardCustomize:
        return MaterialPageRoute(builder: (_) => const WalletCardCustomizeScreen());
      case walletCardUpgrade:
        return MaterialPageRoute(builder: (_) => const WalletCardUpgradeScreen());
      case orderMessages:
        final args = settings.arguments;
        if (args != null) {
          return MaterialPageRoute(
              builder: (_) => OrderMessagesScreen(orderId: args));
        }
        return _errorRoute('Missing order id');
      case merchantShop:
        return MaterialPageRoute(builder: (_) => const MyShopScreen());
      case merchantProducts:
        return MaterialPageRoute(builder: (_) => const MyProductsScreen());
      case merchantEarnings:
        return MaterialPageRoute(builder: (_) => const EarningsScreen());
      case sellerOrders:
        return MaterialPageRoute(builder: (_) => const SellerOrdersScreen());
      case sellerOrderDetail:
        final args = settings.arguments;
        if (args != null) {
          return MaterialPageRoute(
              builder: (_) => SellerOrderDetailScreen(orderId: args));
        }
        return _errorRoute('Missing order id');
      case sellerCategories:
        return MaterialPageRoute(builder: (_) => const SellerCategoriesScreen());
      case sellerBankAccount:
        return MaterialPageRoute(builder: (_) => const SellerBankAccountScreen());
      case sellerWithdrawals:
        return MaterialPageRoute(builder: (_) => const SellerWithdrawalsScreen());
      case sellerMetrics:
        return MaterialPageRoute(builder: (_) => const SellerMetricsScreen());
      case sellerEarningsAnalytics:
        return MaterialPageRoute(
            builder: (_) => const SellerEarningsAnalyticsScreen());
      case sellerEscrowHolds:
        return MaterialPageRoute(builder: (_) => const SellerEscrowHoldsScreen());
      case merchantServicesManage:
        return MaterialPageRoute(builder: (_) => const MerchantServicesScreen());
      case merchantCoverageAreas:
        return MaterialPageRoute(
            builder: (_) => const MerchantCoverageAreasScreen());
      case merchantServiceRequestsManage:
        return MaterialPageRoute(
            builder: (_) => const MerchantServiceRequestsScreen());
      case merchantServiceRequestDetail:
        final args = settings.arguments;
        if (args != null) {
          return MaterialPageRoute(
            builder: (_) => MerchantServiceRequestDetailScreen(requestId: args),
          );
        }
        return _errorRoute('Missing request id');
      case riderDispatchOffers:
        return MaterialPageRoute(builder: (_) => const DispatchOffersScreen());
      case riderAvailability:
        return MaterialPageRoute(
            builder: (_) => const RiderAvailabilityScreen());
      case riderStats:
        return MaterialPageRoute(builder: (_) => const RiderStatsScreen());
      case riderOrders:
        return MaterialPageRoute(builder: (_) => const RiderOrdersScreen());
      case riderOrderDetail:
        final args = settings.arguments;
        if (args != null) {
          return MaterialPageRoute(
              builder: (_) => RiderOrderDetailScreen(orderId: args));
        }
        return _errorRoute('Missing order id');
      case riderProfile:
        return MaterialPageRoute(builder: (_) => const RiderProfileScreen());
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(message),
          ),
        ),
      ),
    );
  }
}
