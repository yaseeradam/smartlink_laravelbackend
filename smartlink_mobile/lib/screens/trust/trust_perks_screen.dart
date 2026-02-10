import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';

class TrustPerksScreen extends StatefulWidget {
  const TrustPerksScreen({super.key});

  @override
  State<TrustPerksScreen> createState() => _TrustPerksScreenState();
}

class _TrustPerksScreenState extends State<TrustPerksScreen> {
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
      final res = await ApiClient.instance.getJson('trust/perks');
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
    final perks = (_data?['perks'] as List?) ?? const [];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Trust perks')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null)
              ...perks.whereType<Map>().map((p) {
                final m = p.cast<String, dynamic>();
                final title = (m['title'] as String?) ?? '';
                final active = (m['active'] as bool?) ?? false;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: active ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.40)) : null,
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
                          color: active
                              ? AppTheme.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12)
                              : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6)),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          active ? Icons.check_circle_outline : Icons.lock_outline,
                          color: active ? AppTheme.primaryColor : (isDark ? Colors.white60 : Colors.black45),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title.isEmpty ? 'Perk' : title,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Text(
                        active ? 'Unlocked' : 'Locked',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: active ? AppTheme.primaryColor : (isDark ? Colors.white60 : Colors.black45),
                            ),
                      ),
                    ],
                  ),
                );
              }),
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
            'Couldn’t load perks',
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

