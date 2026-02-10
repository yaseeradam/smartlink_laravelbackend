import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _settings = const {};

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
      final res = await ApiClient.instance.getJson('notifications/settings');
      if (!mounted) return;
      setState(() => _settings = res);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _update(String key, bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _settings = {..._settings, key: value});
    try {
      final res = await ApiClient.instance.postJson(
        'notifications/settings',
        body: _settings,
      );
      if (!mounted) return;
      setState(() => _settings = res);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Notification settings')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: CircularProgressIndicator(),
                ),
              ),
            if (!_loading && _error != null)
              _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null)
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
                    _Toggle(
                      title: 'Order updates',
                      subtitle: 'Order status changes, delivery updates',
                      value: (_settings['order_updates'] as bool?) ?? true,
                      onChanged: (v) => _update('order_updates', v),
                    ),
                    const Divider(height: 1),
                    _Toggle(
                      title: 'Mission updates',
                      subtitle: 'Dispatch offers and rider missions',
                      value: (_settings['mission_updates'] as bool?) ?? true,
                      onChanged: (v) => _update('mission_updates', v),
                    ),
                    const Divider(height: 1),
                    _Toggle(
                      title: 'Payout updates',
                      subtitle: 'Wallet, withdrawals, and earnings',
                      value: (_settings['payout_updates'] as bool?) ?? true,
                      onChanged: (v) => _update('payout_updates', v),
                    ),
                    const Divider(height: 1),
                    _Toggle(
                      title: 'Trust updates',
                      subtitle: 'Score changes, perks and badges',
                      value: (_settings['trust_updates'] as bool?) ?? true,
                      onChanged: (v) => _update('trust_updates', v),
                    ),
                    const Divider(height: 1),
                    _Toggle(
                      title: 'Promotions',
                      subtitle: 'Sales and marketing messages',
                      value: (_settings['promotions'] as bool?) ?? true,
                      onChanged: (v) => _update('promotions', v),
                    ),
                    const Divider(height: 1),
                    _Toggle(
                      title: 'Security alerts',
                      subtitle: 'Login alerts and suspicious activity',
                      value: (_settings['security_alerts'] as bool?) ?? true,
                      onChanged: (v) => _update('security_alerts', v),
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

class _Toggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
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
      title: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
      ),
      activeThumbColor: AppTheme.primaryColor,
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
            'Couldn’t load settings',
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

