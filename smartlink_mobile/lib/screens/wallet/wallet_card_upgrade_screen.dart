import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';

class WalletCardUpgradeScreen extends StatefulWidget {
  const WalletCardUpgradeScreen({super.key});

  @override
  State<WalletCardUpgradeScreen> createState() => _WalletCardUpgradeScreenState();
}

class _WalletCardUpgradeScreenState extends State<WalletCardUpgradeScreen> {
  bool _saving = false;

  Future<void> _upgrade() async {
    setState(() => _saving = true);
    try {
      await ApiClient.instance.postJson('wallet/card/upgrade');
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Upgrade card')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium card',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Premium theme and perks (demo).',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _saving ? null : _upgrade,
            icon: const Icon(Icons.workspace_premium_outlined),
            label: Text(_saving ? 'Upgrading…' : 'Upgrade now'),
          ),
        ],
      ),
    );
  }
}

