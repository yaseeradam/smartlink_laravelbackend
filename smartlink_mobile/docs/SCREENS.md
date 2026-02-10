# SmartLink Mobile Screens (Draft)

This file is derived from backend route domains in `../smartlink-api/routes/api.php` and represents the screens the mobile app should cover.

## Auth
- Login (`AppRouter.auth`, `AppRouter.login`): Email/phone + password (no OTP yet)
- Register (`AppRouter.register`): Role selection + account creation (no OTP yet)

## Customer (Buyer)
- Home: `CustomerHomeScreen`
- Explore / Services: `ServicesHomeScreen`
- Feed: `FeedScreen`
- Search: `SearchScreen`
- Search filters (backend reference): `SearchFiltersScreen` (`AppRouter.searchFilters`)
- Shop detail: `ShopDetailScreen`
- Shop reviews: `ShopReviewsScreen` (push from `ShopDetailScreen`)
- Product detail: `ProductDetailScreen`
- Categories: `CategoriesScreen` (`AppRouter.categories`)
- Category products: `CategoryProductsScreen` (push from `CategoriesScreen`)
- Favorites: `FavoritesScreen` (`AppRouter.favorites`)
- Cart: `CartScreen`
- Checkout: `CheckoutScreen`
- Orders: `OrdersScreen`, `OrderTrackingScreen`
- Order chat: `OrderMessagesScreen` (`AppRouter.orderMessages`)
- Wallet: `WalletScreen`
- Wallet card: `WalletCardScreen` (`AppRouter.walletCard`) + customize/upgrade routes
- Wallet transactions: `WalletTransactionsScreen` (`AppRouter.walletTransactions`) + detail route
- Profile/Settings: `ProfileScreen`
- Security: `SecurityScreen`
- Addresses: `AddressListScreen` (+ `AddressEditScreen`)
- Zones: `ZonePickerScreen`
- Locations: `StatePickerScreen`, `CityPickerScreen` (used by `AddressEditScreen`)
- On-site services:
  - Services list/detail: `ServicesHomeScreen`, `ServiceDetailScreen`
  - Requests list/detail/create: `ServiceRequestsScreen`, `ServiceRequestDetailScreen`, `ServiceRequestCreateScreen`
  - Disputes (placeholder): `DisputesScreen`
- Notifications (placeholder): `NotificationsScreen`
- Notification settings: `NotificationSettingsScreen` (`AppRouter.notificationSettings`)
- Messages (placeholder): `MessagesScreen`
- Returns (placeholder): `ReturnsScreen`
- Trust Center: `TrustCenterScreen` (`AppRouter.trustCenter`) + score/analysis/perks/network screens
- Referrals: `ReferralsScreen` (`AppRouter.referrals`)

## Merchant (Seller)
- Merchant home: `MerchantHomeScreen`
- My shop (placeholder): `MyShopScreen`
- My products (placeholder): `MyProductsScreen`
- Earnings (placeholder): `EarningsScreen`
- Seller orders (placeholder): `SellerOrdersScreen` (`AppRouter.sellerOrders`) + detail screen
- Seller categories (placeholder): `SellerCategoriesScreen` (`AppRouter.sellerCategories`)
- Bank account (placeholder): `SellerBankAccountScreen` (`AppRouter.sellerBankAccount`)
- Withdrawals (placeholder): `SellerWithdrawalsScreen` (`AppRouter.sellerWithdrawals`)
- Metrics (placeholder): `SellerMetricsScreen` (`AppRouter.sellerMetrics`)
- Earnings analytics (placeholder): `SellerEarningsAnalyticsScreen` (`AppRouter.sellerEarningsAnalytics`)
- Escrow holds (placeholder): `SellerEscrowHoldsScreen` (`AppRouter.sellerEscrowHolds`)
- Wallet: `WalletScreen` (seller bank accounts/withdrawals TBD)
- Merchant on-site services:
  - Services management (placeholder): `MerchantServicesScreen` (`AppRouter.merchantServicesManage`)
  - Coverage areas (placeholder): `MerchantCoverageAreasScreen` (`AppRouter.merchantCoverageAreas`)
  - Service requests (placeholder): `MerchantServiceRequestsScreen` (`AppRouter.merchantServiceRequestsManage`)
- Disputes (placeholder): `DisputesScreen`

## Rider (Pilot)
- Rider home: `RiderHomeScreen`
- Dispatch offers (placeholder): `DispatchOffersScreen`
- Availability (placeholder): `RiderAvailabilityScreen`
- Stats (placeholder): `RiderStatsScreen`
- My deliveries (placeholder): `RiderOrdersScreen` (`AppRouter.riderOrders`) + detail + proof upload screen
- Rider profile (placeholder): `RiderProfileScreen` (`AppRouter.riderProfile`)
- Wallet: `WalletScreen`

## Notes
- Backend roles map to mobile roles via `lib/core/utils/app_role.dart`:
  - `buyer` → Customer
  - `seller` → Merchant
  - `rider` → Pilot
- OTP endpoints exist in backend and `OtpVerifyScreen` exists in mobile, but OTP is intentionally skipped for now.
