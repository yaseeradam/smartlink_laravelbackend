import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/security_provider.dart';
import 'set_pin_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SecurityProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Security')),
      body: !provider.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Transaction PIN helps protect wallet and protected payments.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: Icons.pin_outlined,
                        title: provider.hasPin ? 'Change transaction PIN' : 'Set transaction PIN',
                        subtitle: provider.hasPin ? 'Old PIN required' : '4–10 digits',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SetPinScreen()),
                        ),
                      ),
                      const Divider(height: 1),
                      _ToggleRow(
                        icon: Icons.fingerprint_outlined,
                        title: 'Biometric',
                        subtitle: 'Quick unlock (simulated)',
                        value: provider.settings.biometricEnabled,
                        onChanged: (v) => context.read<SecurityProvider>().updateSettings(biometricEnabled: v),
                      ),
                      const Divider(height: 1),
                      _ToggleRow(
                        icon: Icons.verified_user_outlined,
                        title: 'Two-factor',
                        subtitle: 'Extra protection (simulated)',
                        value: provider.settings.twoFactorEnabled,
                        onChanged: (v) => context.read<SecurityProvider>().updateSettings(twoFactorEnabled: v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (provider.hasPin)
                  OutlinedButton(
                    onPressed: () async {
                      await context.read<SecurityProvider>().clearPin();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction PIN removed.')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDC2626)),
                      foregroundColor: const Color(0xFFDC2626),
                    ),
                    child: const Text('Remove PIN'),
                  ),
              ],
            ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

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
      child: child,
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
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
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SwitchListTile.adaptive(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      activeThumbColor: AppTheme.primaryColor,
    );
  }
}

