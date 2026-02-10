import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class WalletCardScreen extends StatefulWidget {
  const WalletCardScreen({super.key});

  @override
  State<WalletCardScreen> createState() => _WalletCardScreenState();
}

class _WalletCardScreenState extends State<WalletCardScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _card;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.getJson('wallet/card');
      if (!mounted) return;
      setState(() => _card = res['data'] is Map ? (res['data'] as Map).cast<String, dynamic>() : res);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardholder = (_card?['cardholder_name'] as String?) ?? '';
    final theme = (_card?['theme'] as String?) ?? 'default';
    final isPremium = (_card?['is_premium'] as bool?) ?? false;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Wallet card')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isPremium
                        ? const [Color(0xFF0F172A), Color(0xFF1F2937)]
                        : const [AppTheme.primaryColor, Color(0xFF1ba84f)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SmartLink',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isPremium ? 'Premium' : 'Standard',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      cardholder.isEmpty ? 'Cardholder' : cardholder,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Theme: $theme',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),
            Container(
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
                children: [
                  ListTile(
                    onTap: () async {
                      final changed = await Navigator.pushNamed(context, AppRouter.walletCardCustomize);
                      if (changed == true) {
                        await _load();
                      }
                    },
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.palette_outlined, color: AppTheme.primaryColor),
                    ),
                    title: Text(
                      'Customize',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    onTap: () async {
                      final changed = await Navigator.pushNamed(context, AppRouter.walletCardUpgrade);
                      if (changed == true) {
                        await _load();
                      }
                    },
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.workspace_premium_outlined, color: AppTheme.primaryColor),
                    ),
                    title: Text(
                      'Upgrade',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Couldn’t load wallet card',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

