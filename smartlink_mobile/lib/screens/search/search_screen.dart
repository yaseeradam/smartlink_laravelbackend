import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/shimmer_box.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  String _query = '';
  String _category = 'All';
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await rootBundle.loadString('assets/mock_data/products.json');
      final data = (json.decode(response) as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      setState(() => _products = data);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> get _categories {
    final set = <String>{'All'};
    for (final p in _products) {
      final c = (p['category'] as String?)?.trim();
      if (c != null && c.isNotEmpty) set.add(_prettyCategory(c));
    }
    return set.toList();
  }

  static String _prettyCategory(String raw) {
    if (raw.isEmpty) return raw;
    final normalized = raw.replaceAll('_', ' ').trim();
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _query.trim().toLowerCase();

    return _products.where((p) {
      final title = ((p['title'] as String?) ?? '').toLowerCase();
      final seller = ((p['sellerName'] as String?) ?? '').toLowerCase();
      final rawCategory = ((p['category'] as String?) ?? '');
      final category = _prettyCategory(rawCategory);

      final matchesQuery = q.isEmpty || title.contains(q) || seller.contains(q);
      final matchesCategory = _category == 'All' || category == _category;
      return matchesQuery && matchesCategory;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _filtered;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search products or storefronts',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final c = _categories[index];
                  final selected = c == _category;
                  return InkWell(
                    onTap: () => setState(() => _category = c),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? (isDark ? Colors.white : AppTheme.textMain)
                            : (isDark ? AppTheme.surfaceDark : Colors.white),
                        borderRadius: BorderRadius.circular(999),
                        border: selected
                            ? null
                            : Border.all(
                                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                              ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        c,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: selected
                                  ? (isDark ? Colors.black : Colors.white)
                                  : (isDark ? Colors.white : AppTheme.textMain),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            if (_isLoading)
              _LoadingGrid(isDark: isDark)
            else if (items.isEmpty)
              _EmptyState(isDark: isDark)
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 250,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) => _ProductTile(product: items[index]),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = (product['title'] as String?) ?? '';
    final seller = (product['sellerName'] as String?) ?? '';
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final rating = (product['rating'] as num?)?.toDouble();
    final images = (product['images'] is List) ? (product['images'] as List).cast<String>() : <String>[];
    final imageUrl = images.isEmpty ? '' : images.first;

    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRouter.productDetail, arguments: product),
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerBox(
                      height: 120,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 120,
                      color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                      child: const Icon(Icons.image_outlined),
                    ),
                  ),
                  if (rating != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.textMain,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seller,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            Formatting.naira(price, decimalDigits: 0),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<CartProvider>().addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        },
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        icon: const Icon(Icons.add_circle_outline),
                        color: AppTheme.primaryColor,
                      ),
                    ],
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

class _LoadingGrid extends StatelessWidget {
  final bool isDark;
  const _LoadingGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 250,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 120, borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
              SizedBox(height: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 14, width: 140),
                    SizedBox(height: 8),
                    ShimmerBox(height: 12, width: 110),
                    SizedBox(height: 14),
                    ShimmerBox(height: 16, width: 90),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 48, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(height: 10),
          Text(
            'No results',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different keyword or category.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
          ),
        ],
      ),
    );
  }
}
