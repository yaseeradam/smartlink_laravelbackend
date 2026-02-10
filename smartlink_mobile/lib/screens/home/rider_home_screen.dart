import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/bottom_nav_bar.dart';

class RiderHomeScreen extends StatelessWidget {
  const RiderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    Widget card({
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
        title: const Text('Pilot'),
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
                  child: const Icon(Icons.two_wheeler_outlined,
                      color: AppTheme.primaryColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispatch & deliveries',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Accept nearby jobs and get paid fast.',
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
          card(
            icon: Icons.local_shipping_outlined,
            title: 'Dispatch offers',
            subtitle: 'Accept or decline nearby jobs',
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.riderDispatchOffers),
          ),
          const SizedBox(height: 12),
          card(
            icon: Icons.power_settings_new,
            title: 'Availability',
            subtitle: 'Go online/offline',
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.riderAvailability),
          ),
          const SizedBox(height: 12),
          card(
            icon: Icons.query_stats_outlined,
            title: 'Stats',
            subtitle: 'Trips, acceptance rate, earnings',
            onTap: () => Navigator.pushNamed(context, AppRouter.riderStats),
          ),
          const SizedBox(height: 12),
          card(
            icon: Icons.receipt_long_outlined,
            title: 'Orders',
            subtitle: 'Track deliveries and proofs',
            onTap: () => Navigator.pushNamed(context, AppRouter.riderOrders),
          ),
          const SizedBox(height: 12),
          card(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Wallet',
            subtitle: 'Payouts and earnings',
            onTap: () => Navigator.pushNamed(context, AppRouter.wallet),
          ),
          const SizedBox(height: 12),
          card(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Settings, KYC, and security',
            onTap: () => Navigator.pushNamed(context, AppRouter.riderProfile),
          ),
          const SizedBox(height: 28),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}
