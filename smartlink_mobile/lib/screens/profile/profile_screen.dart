import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../providers/zone_provider.dart';
import '../zones/zone_picker_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final theme = context.watch<ThemeProvider>();
    final zone = context.watch<ZoneProvider>().selectedZoneLabel;

    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    final user = auth.currentUser;
    final name = ((user?['name'] as String?) ?? 'Guest').trim().isEmpty
        ? 'Guest'
        : ((user?['name'] as String?) ?? 'Guest').trim();
    final phone = ((user?['phone'] as String?) ?? '').trim();
    final email = ((user?['email'] as String?) ?? '').trim();

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ProfileHeaderCard(
            name: name,
            phone: phone,
            email: email,
            isVerified: auth.isPhoneVerified,
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuickAction(
                icon: Icons.receipt_long_outlined,
                label: 'Orders',
                onTap: () => Navigator.pushNamed(context, AppRouter.orders),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Wallet',
                onTap: () => Navigator.pushNamed(context, AppRouter.wallet),
              ),
              const SizedBox(width: 12),
              _QuickAction(
                icon: Icons.verified_user_outlined,
                label: 'KYC',
                onTap: () => Navigator.pushNamed(context, AppRouter.kyc),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Account'),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.place_outlined,
            title: 'My zone',
            subtitle: zone,
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.zones,
              arguments: const ZonePickerArgs(mode: ZonePickerMode.home),
            ),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.location_on_outlined,
            title: 'My addresses',
            subtitle: 'Manage delivery addresses',
            onTap: () => Navigator.pushNamed(context, AppRouter.addresses),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.lock_outline,
            title: 'Security',
            subtitle: 'Transaction PIN, biometrics, 2FA',
            onTap: () => Navigator.pushNamed(context, AppRouter.security),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.grid_view_outlined,
            title: 'Categories',
            subtitle: 'Browse product categories',
            onTap: () => Navigator.pushNamed(context, AppRouter.categories),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.favorite_border_rounded,
            title: 'Favorites',
            subtitle: 'Saved shops and items',
            onTap: () => Navigator.pushNamed(context, AppRouter.favorites),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.verified_user_outlined,
            title: 'Trust Center',
            subtitle: 'Score, perks, and network',
            onTap: () => Navigator.pushNamed(context, AppRouter.trustCenter),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.card_giftcard_outlined,
            title: 'Referrals',
            subtitle: 'Invite friends and earn perks',
            onTap: () => Navigator.pushNamed(context, AppRouter.referrals),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Updates, promos and alerts',
            onTap: () => Navigator.pushNamed(context, AppRouter.notifications),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.tune_outlined,
            title: 'Notification settings',
            subtitle: 'Choose what you get notified about',
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.notificationSettings),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.chat_bubble_outline,
            title: 'Messages',
            subtitle: 'Support and conversations',
            onTap: () => Navigator.pushNamed(context, AppRouter.messages),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.assignment_return_outlined,
            title: 'Returns',
            subtitle: 'Create and track returns',
            onTap: () => Navigator.pushNamed(context, AppRouter.returns),
          ),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Services'),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.home_repair_service_outlined,
            title: 'On-site services',
            subtitle: 'Request quotes with protected payment',
            onTap: () => Navigator.pushNamed(context, AppRouter.services),
          ),
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Wallet'),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.credit_card_outlined,
            title: 'Wallet card',
            subtitle: 'Themes and premium upgrade',
            onTap: () => Navigator.pushNamed(context, AppRouter.walletCard),
          ),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.receipt_long_outlined,
            title: 'Wallet transactions',
            subtitle: 'View history from backend',
            onTap: () =>
                Navigator.pushNamed(context, AppRouter.walletTransactions),
          ),
          if (role == AppRole.merchant) ...[
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Merchant'),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.storefront_outlined,
              title: 'My shop',
              subtitle: 'Storefront setup and metrics',
              onTap: () => Navigator.pushNamed(context, AppRouter.merchantShop),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.shopping_bag_outlined,
              title: 'Seller orders',
              subtitle: 'Fulfill and dispatch orders',
              onTap: () => Navigator.pushNamed(context, AppRouter.sellerOrders),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.category_outlined,
              title: 'Seller categories',
              subtitle: 'Manage categories for your shop',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.sellerCategories),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.inventory_2_outlined,
              title: 'My products',
              subtitle: 'Manage your catalog',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.merchantProducts),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.payments_outlined,
              title: 'Earnings',
              subtitle: 'Sales and payouts',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.merchantEarnings),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.query_stats_outlined,
              title: 'Metrics',
              subtitle: 'Views and conversions',
              onTap: () => Navigator.pushNamed(context, AppRouter.sellerMetrics),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.insights_outlined,
              title: 'Earnings analytics',
              subtitle: 'Charts and trends',
              onTap: () => Navigator.pushNamed(
                  context, AppRouter.sellerEarningsAnalytics),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.lock_outline,
              title: 'Escrow holds',
              subtitle: 'Orders with held funds',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.sellerEscrowHolds),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.account_balance_outlined,
              title: 'Bank account',
              subtitle: 'Set payout destination',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.sellerBankAccount),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.payments_outlined,
              title: 'Withdrawals',
              subtitle: 'Request and track payouts',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.sellerWithdrawals),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.home_repair_service_outlined,
              title: 'Manage services',
              subtitle: 'Create and toggle your services',
              onTap: () => Navigator.pushNamed(
                  context, AppRouter.merchantServicesManage),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.map_outlined,
              title: 'Coverage areas',
              subtitle: 'Where you can serve',
              onTap: () => Navigator.pushNamed(
                  context, AppRouter.merchantCoverageAreas),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.receipt_long_outlined,
              title: 'Service requests',
              subtitle: 'Quotes and progress updates',
              onTap: () => Navigator.pushNamed(
                  context, AppRouter.merchantServiceRequestsManage),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.gavel_outlined,
              title: 'Disputes',
              subtitle: 'Resolve issues and disputes',
              onTap: () => Navigator.pushNamed(context, AppRouter.disputes),
            ),
          ],
          if (role == AppRole.rider) ...[
            const SizedBox(height: 20),
            const _SectionHeader(title: 'Pilot'),
            const SizedBox(height: 10),
            _MenuTile(
              icon: Icons.receipt_long_outlined,
              title: 'My deliveries',
              subtitle: 'Pickup and delivery proofs',
              onTap: () => Navigator.pushNamed(context, AppRouter.riderOrders),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.local_shipping_outlined,
              title: 'Dispatch offers',
              subtitle: 'Accept nearby jobs',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.riderDispatchOffers),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.power_settings_new,
              title: 'Availability',
              subtitle: 'Go online/offline',
              onTap: () =>
                  Navigator.pushNamed(context, AppRouter.riderAvailability),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.query_stats_outlined,
              title: 'Stats',
              subtitle: 'Trips and performance',
              onTap: () => Navigator.pushNamed(context, AppRouter.riderStats),
            ),
            const SizedBox(height: 12),
            _MenuTile(
              icon: Icons.person_outline,
              title: 'Rider profile',
              subtitle: 'Vehicle and profile info',
              onTap: () => Navigator.pushNamed(context, AppRouter.riderProfile),
            ),
          ],
          const SizedBox(height: 20),
          const _SectionHeader(title: 'Preferences'),
          const SizedBox(height: 10),
          _MenuTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark mode',
            subtitle: theme.isDarkMode ? 'On' : 'Off',
            onTap: () => theme.toggleTheme(),
            trailing: Switch(
              value: theme.isDarkMode,
              onChanged: (_) => theme.toggleTheme(),
              activeThumbColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 18),
          if (!auth.isAuthenticated)
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRouter.auth),
              child: const Text('Sign in / Create account'),
            )
          else
            OutlinedButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRouter.auth, (r) => false);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFDC2626)),
                foregroundColor: const Color(0xFFDC2626),
              ),
              child: const Text('Log out'),
            ),
          const SizedBox(height: 28),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String phone;
  final String email;
  final bool isVerified;
  final bool isDark;

  const _ProfileHeaderCard({
    required this.name,
    required this.phone,
    required this.email,
    required this.isVerified,
    required this.isDark,
  });

  String _initialsFor(String value) {
    final parts =
        value.trim().split(RegExp(r'\\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    final first = parts.first.isEmpty ? '' : parts.first[0];
    final second =
        parts.length > 1 ? (parts.last.isEmpty ? '' : parts.last[0]) : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor
                      .withValues(alpha: isDark ? 0.24 : 0.14),
                  border: Border.all(
                    color: AppTheme.primaryColor
                        .withValues(alpha: isDark ? 0.26 : 0.18),
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9),
                  child: Text(
                    _initialsFor(name),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ),
              if (isVerified)
                const Positioned(
                  right: -4,
                  bottom: -4,
                  child: Icon(Icons.verified,
                      size: 20, color: AppTheme.primaryColor),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          size: 18, color: AppTheme.primaryColor),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  phone.isNotEmpty ? phone : 'Sign in to start shopping',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black45,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor
                      .withValues(alpha: isDark ? 0.22 : 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppTheme.textMain,
          ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor
                    .withValues(alpha: isDark ? 0.22 : 0.12),
                borderRadius: BorderRadius.circular(16),
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
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
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
            trailing ??
                Icon(Icons.chevron_right,
                    color: isDark ? Colors.white60 : Colors.black45),
          ],
        ),
      ),
    );
  }
}
