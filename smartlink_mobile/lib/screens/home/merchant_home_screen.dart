import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/bottom_nav_bar.dart';

class MerchantHomeScreen extends StatelessWidget {
  const MerchantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    Widget tile({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor
                      .withValues(alpha: isDark ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: isDark ? Colors.white60 : Colors.black45),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Merchant'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRouter.kyc),
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Verify'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                  blurRadius: 26,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor
                        .withValues(alpha: isDark ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.storefront_outlined,
                      color: AppTheme.primaryColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your storefront',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add products, manage orders, and grow your trust score.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                              height: 1.35,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          tile(
            icon: Icons.storefront_outlined,
            title: 'My shop',
            subtitle: 'Storefront profile and metrics',
            onTap: () => Navigator.pushNamed(context, AppRouter.merchantShop),
          ),
          const SizedBox(height: 12),
          tile(
            icon: Icons.inventory_2_outlined,
            title: 'My products',
            subtitle: 'Manage your catalog',
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.merchantProducts),
          ),
          const SizedBox(height: 12),
          tile(
            icon: Icons.payments_outlined,
            title: 'Earnings',
            subtitle: 'Sales, pending and payouts',
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.merchantEarnings),
          ),
          const SizedBox(height: 12),
          tile(
            icon: Icons.shopping_bag_outlined,
            title: 'Orders',
            subtitle: 'View and fulfill customer orders',
            onTap: () => Navigator.pushNamed(context, AppRouter.sellerOrders),
          ),
          const SizedBox(height: 12),
          tile(
            icon: Icons.category_outlined,
            title: 'Categories',
            subtitle: 'Organize your catalog',
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.sellerCategories),
          ),
          const SizedBox(height: 12),
          tile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            subtitle: 'Track balances and escrow holds',
            onTap: () => Navigator.pushNamed(context, AppRouter.wallet),
          ),
          const SizedBox(height: 12),
          tile(
            icon: Icons.payments_outlined,
            title: 'Withdrawals',
            subtitle: 'Request payouts to your bank',
            onTap: () => Navigator.pushNamed(
                context, AppRouter.sellerWithdrawals),
          ),
          const SizedBox(height: 12),
          tile(
            icon: Icons.gavel_outlined,
            title: 'Disputes',
            subtitle: 'Resolve issues with buyers',
            onTap: () => Navigator.pushNamed(context, AppRouter.disputes),
          ),
          const SizedBox(height: 12),
          tile(
            icon: Icons.home_repair_service_outlined,
            title: 'On-site services',
            subtitle: 'Offer protected on-site services',
            onTap: () => Navigator.pushNamed(
                context, AppRouter.merchantServiceRequestsManage),
          ),
          const SizedBox(height: 12),
          tile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Settings, KYC, and security',
            onTap: () => Navigator.pushNamed(context, AppRouter.profile),
          ),
          const SizedBox(height: 28),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
