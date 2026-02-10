import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppTheme.surfaceDark : Colors.white;
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    void navigateTo(int index) {
      final targetRoute = switch (index) {
        0 => AppRouter.home,
        1 => AppRouter.services,
        2 => AppRouter.wallet,
        3 => AppRouter.orders,
        4 => AppRouter.profile,
        _ => AppRouter.home,
      };

      if (index == currentIndex) return;
      Navigator.pushReplacementNamed(context, targetRoute);
    }

    return SafeArea(
      top: false,
      child: AnimatedContainer(
        duration: AppTheme.normalAnimation,
        curve: AppTheme.smoothCurve,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusLg),
            topRight: Radius.circular(AppTheme.radiusLg),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
              blurRadius: 40,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusLg),
            topRight: Radius.circular(AppTheme.radiusLg),
          ),
          child: NavigationBar(
            height: 70,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            indicatorColor:
                AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.1),
            indicatorShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            selectedIndex: currentIndex,
            onDestinationSelected: navigateTo,
            animationDuration: AppTheme.normalAnimation,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, 
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: const Icon(Icons.home_rounded, color: Colors.white),
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.grid_view_outlined,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: const Icon(Icons.grid_view_rounded, color: Colors.white),
                ),
                label: 'Explore',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_balance_wallet_outlined,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
                ),
                label: 'Wallet',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                ),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline,
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary),
                selectedIcon: ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: const Icon(Icons.person_rounded, color: Colors.white),
                ),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
