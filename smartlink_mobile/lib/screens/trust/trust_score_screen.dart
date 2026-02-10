import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';

class TrustScoreScreen extends StatefulWidget {
  const TrustScoreScreen({super.key});

  @override
  State<TrustScoreScreen> createState() => _TrustScoreScreenState();
}

class _TrustScoreScreenState extends State<TrustScoreScreen> {
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
      final res = await ApiClient.instance.getJson('trust/score');
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
    final score = (_data?['score'] as num?)?.toDouble();
    final level = (_data?['level'] as String?) ?? '';
    final badges = (_data?['badges'] is List) ? (_data?['badges'] as List).map((e) => e.toString()).toList(growable: false) : const <String>[];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Trust score')),
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
                      (score ?? 0.0).toStringAsFixed(1),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.isEmpty ? 'basic' : level,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: score == null ? null : (score.clamp(0, 100) / 100),
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Badges',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    if (badges.isEmpty)
                      Text(
                        'No badges yet.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: badges
                            .map(
                              (b) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
                                  ),
                                ),
                                child: Text(
                                  b,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                            )
                            .toList(growable: false),
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
            'Couldn’t load trust score',
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

