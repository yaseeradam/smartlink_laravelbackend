import 'package:flutter/material.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class TrustCenterScreen extends StatelessWidget {
  const TrustCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Trust Center')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your trust score unlocks perks like faster pilot matching and higher limits.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Tile(
            icon: Icons.shield_outlined,
            title: 'Trust score',
            subtitle: 'Current score, level & badges',
            onTap: () => Navigator.pushNamed(context, AppRouter.trustScore),
          ),
          const SizedBox(height: 12),
          _Tile(
            icon: Icons.analytics_outlined,
            title: 'Analysis',
            subtitle: 'See what affects your score',
            onTap: () => Navigator.pushNamed(context, AppRouter.trustAnalysis),
          ),
          const SizedBox(height: 12),
          _Tile(
            icon: Icons.card_giftcard_outlined,
            title: 'Perks',
            subtitle: 'Unlocks & rewards',
            onTap: () => Navigator.pushNamed(context, AppRouter.trustPerks),
          ),
          const SizedBox(height: 12),
          _Tile(
            icon: Icons.group_outlined,
            title: 'Network',
            subtitle: 'Invites & verified referrals progress',
            onTap: () => Navigator.pushNamed(context, AppRouter.trustNetwork),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

