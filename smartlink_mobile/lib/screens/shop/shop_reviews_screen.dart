import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';

class ShopReviewsScreen extends StatefulWidget {
  final Object shopId;
  final String shopName;

  const ShopReviewsScreen({
    super.key,
    required this.shopId,
    required this.shopName,
  });

  @override
  State<ShopReviewsScreen> createState() => _ShopReviewsScreenState();
}

class _ShopReviewsScreenState extends State<ShopReviewsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _items = const [];

  int? get _id {
    final raw = widget.shopId;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _id;
    if (id == null) {
      setState(() {
        _loading = false;
        _error = 'Reviews require a backend shop id.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.getJson('shops/$id/reviews');
      final summary = (res['summary'] is Map) ? (res['summary'] as Map).cast<String, dynamic>() : null;
      final raw = (res['data'] as List?) ?? const [];
      final items = raw
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _items = items;
      });
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
    final avg = (_summary?['average'] as num?)?.toDouble() ?? 0.0;
    final total = (_summary?['total'] as num?)?.toInt() ?? _items.length;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text('${widget.shopName} reviews')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
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
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.star_rounded, color: AppTheme.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          avg.toStringAsFixed(2),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$total reviews',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: isDark ? Colors.white54 : Colors.black45),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator())),
            if (!_loading && _error != null)
              _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null && _items.isEmpty)
              _EmptyCard(isDark: isDark, message: 'No reviews yet.'),
            if (!_loading && _error == null)
              ..._items.map((r) {
                final stars = (r['stars'] as num?)?.toDouble() ?? 0.0;
                final comment = (r['comment'] as String?) ?? '';
                final createdAt = (r['created_at'] as String?) ?? '';
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < stars.round() ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 18,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const Spacer(),
                          if (createdAt.isNotEmpty)
                            Text(
                              createdAt,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white60 : Colors.black45,
                                  ),
                            ),
                        ],
                      ),
                      if (comment.trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          comment,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.35,
                              ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Text(
                        'Protected payment: ratings stay immutable after escrow release.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white60 : Colors.black45,
                            ),
                      ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 24),
            Text(
              'Tip: You can rate after completing an order.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white60 : Colors.black45,
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
            'Couldn’t load reviews',
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

class _EmptyCard extends StatelessWidget {
  final bool isDark;
  final String message;
  const _EmptyCard({required this.isDark, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.rate_review_outlined, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
