import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';

class SearchFiltersScreen extends StatefulWidget {
  const SearchFiltersScreen({super.key});

  @override
  State<SearchFiltersScreen> createState() => _SearchFiltersScreenState();
}

class _SearchFiltersScreenState extends State<SearchFiltersScreen> {
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
      final res = await ApiClient.instance.getJson('search/filters');
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
    final categories = (_data?['categories'] as List?) ?? const [];
    final sortOptions = (_data?['sort_options'] as List?) ?? const [];
    final priceRange = (_data?['price_range'] is Map) ? (_data?['price_range'] as Map).cast<String, dynamic>() : const {};

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Search filters')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null)
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
                      'Price range',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Min: ${priceRange['min'] ?? '—'} • Max: ${priceRange['max'] ?? '—'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Sort options',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    ...sortOptions.whereType<Map>().map((o) {
                      final m = o.cast<String, dynamic>();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.swap_vert_rounded, color: AppTheme.primaryColor, size: 18),
                            const SizedBox(width: 10),
                            Expanded(child: Text((m['label'] as String?) ?? '')),
                            Text(
                              (m['key'] as String?) ?? '',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white60 : Colors.black45),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    Text(
                      'Categories',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    if (categories.isEmpty)
                      Text(
                        'No categories available.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: categories
                            .whereType<Map>()
                            .map((c) => (c['name'] ?? '').toString())
                            .where((e) => e.trim().isNotEmpty)
                            .map(
                              (name) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  name,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w900),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 18),
            Text(
              'This screen is a backend-driven filter reference; the Search UI can use these values.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white60 : Colors.black45),
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
            'Couldn’t load filters',
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

