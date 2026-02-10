import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';
import 'rider_upload_proof_screen.dart';

class RiderOrderDetailScreen extends StatelessWidget {
  final Object orderId;
  const RiderOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    if (role != AppRole.rider) {
      return const _NotAuthorizedScreen(title: 'Order');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text(orderId.toString())),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Action(
            title: 'Upload pickup proof',
            subtitle: 'POST /rider/orders/{order}/pickup-proof',
            icon: Icons.photo_camera_outlined,
            outline: outline,
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RiderUploadProofScreen(
                  orderId: orderId,
                  mode: RiderProofMode.pickup,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Action(
            title: 'Mark picked up',
            subtitle: 'POST /rider/orders/{order}/mark-picked-up',
            icon: Icons.check_circle_outline,
            outline: outline,
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _Action(
            title: 'Upload delivery proof',
            subtitle: 'POST /rider/orders/{order}/delivery-proof',
            icon: Icons.photo_outlined,
            outline: outline,
            isDark: isDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RiderUploadProofScreen(
                  orderId: orderId,
                  mode: RiderProofMode.delivery,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Action(
            title: 'Mark delivered',
            subtitle: 'POST /rider/orders/{order}/mark-delivered',
            icon: Icons.flag_outlined,
            outline: outline,
            isDark: isDark,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color outline;
  final bool isDark;
  final VoidCallback onTap;

  const _Action({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.outline,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: outline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
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
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white60 : Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _NotAuthorizedScreen extends StatelessWidget {
  final String title;
  const _NotAuthorizedScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Not authorized for this section.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

