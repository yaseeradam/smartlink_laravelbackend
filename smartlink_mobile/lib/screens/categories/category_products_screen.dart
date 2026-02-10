import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../widgets/common/shimmer_box.dart';

class CategoryProductsScreen extends StatefulWidget {
  final Map<String, dynamic> category;
  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

  int? get _categoryId {
    final id = widget.category['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    if (id is String) return int.tryParse(id);
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _categoryId;
    if (id == null) {
      setState(() {
        _loading = false;
        _error = 'Missing category id.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.getJson('categories/$id/products');
      final raw = (res['data'] as List?) ?? const [];
      final items = raw
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false);
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Map<String, dynamic> _mapToProductDetail(Map<String, dynamic> apiProduct) {
    final shop = (apiProduct['shop'] is Map) ? (apiProduct['shop'] as Map).cast<String, dynamic>() : null;
    final images = (apiProduct['images'] is List) ? (apiProduct['images'] as List).whereType<String>().toList(growable: false) : const <String>[];
    final price = double.tryParse((apiProduct['price'] ?? '').toString()) ?? 0.0;
    final stockQty = (apiProduct['stock_qty'] as num?)?.toInt() ?? 0;

    return {
      'id': apiProduct['id'],
      'title': (apiProduct['name'] as String?) ?? '',
      'description': (apiProduct['description'] as String?) ?? '',
      'price': price,
      'images': images,
      'sellerName': (shop?['shop_name'] as String?) ?? '',
      'sellerLocation': '',
      'rating': (shop?['trust_score'] as num?)?.toDouble() ?? 0.0,
      'reviewCount': 0,
      'stockQuantity': stockQty,
      'isAvailable': stockQty > 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = (widget.category['name'] as String?) ?? 'Category';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text(name)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null)
              _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null && _items.isEmpty)
              _EmptyCard(isDark: isDark, message: 'No products found in this category.'),
            if (!_loading && _error == null && _items.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                itemBuilder: (context, index) {
                  final p = _items[index];
                  final product = _mapToProductDetail(p);
                  final images = (product['images'] as List).cast<String>();
                  final imageUrl = images.isEmpty ? '' : images.first;
                  final title = (product['title'] as String?) ?? '';
                  final price = (product['price'] as num?)?.toDouble() ?? 0.0;

                  return InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRouter.productDetail,
                      arguments: product,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 24,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              height: 128,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => const ShimmerBox(
                                height: 128,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                height: 128,
                                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_outlined),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  const Spacer(),
                                  Text(
                                    Formatting.naira(price, decimalDigits: 0),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: AppTheme.primaryColor,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
            'Couldn’t load products',
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
          Icon(Icons.inventory_2_outlined, color: isDark ? Colors.white54 : Colors.black45),
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

