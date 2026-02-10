import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class TrustNetworkScreen extends StatefulWidget {
  const TrustNetworkScreen({super.key});

  @override
  State<TrustNetworkScreen> createState() => _TrustNetworkScreenState();
}

class _TrustNetworkScreenState extends State<TrustNetworkScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

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
      final res = await ApiClient.instance.getJson('trust/network');
      if (!mounted) return;
      setState(() => _data = res);
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
    final total = (_data?['total_invites'] as num?)?.toInt() ?? 0;
    final verified = (_data?['verified'] as num?)?.toInt() ?? 0;
    final remaining = (_data?['remaining_to_unlock'] as num?)?.toInt() ?? 0;
    final progress = (_data?['progress_percent'] as num?)?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Trust network')),
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
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(22),
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
                      '$verified verified',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$total total invites • $remaining to unlock next tier',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (progress.clamp(0, 100) / 100),
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.referrals),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Invite friends'),
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
            'Couldn’t load network',
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

