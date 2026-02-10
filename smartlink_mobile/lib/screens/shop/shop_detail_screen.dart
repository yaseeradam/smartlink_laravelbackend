import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/shimmer_box.dart';
import 'shop_reviews_screen.dart';

class ShopDetailScreen extends StatefulWidget {
  final Map<String, dynamic> shop;

  const ShopDetailScreen({super.key, required this.shop});

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await rootBundle.loadString('assets/mock_data/products.json');
      final data = (json.decode(response) as List).cast<Map<String, dynamic>>();
      final sellerId = widget.shop['id'];
      final products = data.where((p) => p['sellerId'] == sellerId).toList();
      if (!mounted) return;
      setState(() => _products = products);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shopName = (widget.shop['name'] as String?) ?? 'Shop';
    final shopImage = (widget.shop['image'] as String?) ?? '';
    final rating = (widget.shop['rating'] as num?)?.toDouble() ?? 0.0;
    final location = (widget.shop['location'] as String?) ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(shopName),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined),
                Positioned(
                  right: -6,
                  top: -6,
                  child: Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      if (cart.itemCount == 0) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          cart.itemCount > 9 ? '9+' : '${cart.itemCount}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: CachedNetworkImage(
                      imageUrl: shopImage,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ShimmerBox(
                        height: 180,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 180,
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        child: const Icon(Icons.store, size: 44),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                shopName,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                            _RatingPill(rating: rating),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Protected Payment: funds stay in escrow until you confirm delivery.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: isDark ? Colors.white70 : Colors.black87,
                                        height: 1.3,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShopReviewsScreen(
                      shopId: widget.shop['id'] ?? 0,
                      shopName: shopName,
                    ),
                  ),
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.rate_review_outlined,
                      color: AppTheme.primaryColor),
                ),
                title: Text(
                  'Reviews',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                subtitle: Text(
                  rating > 0
                      ? '${rating.toStringAsFixed(1)} • Verified ratings'
                      : 'See ratings & feedback',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Products',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  '${_products.length} items',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              _LoadingList(isDark: isDark)
            else if (_products.isEmpty)
              _EmptyState(isDark: isDark)
            else
              ..._products.map((p) => _ProductRow(product: p)),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final double rating;
  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = (product['title'] as String?) ?? '';
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final imageUrl = (product['images'] is List && (product['images'] as List).isNotEmpty)
        ? (product['images'] as List).first as String
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRouter.productDetail,
          arguments: product,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const ShimmerBox(
                    width: 64,
                    height: 64,
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Formatting.naira(price, decimalDigits: 0),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  final bool isDark;
  const _LoadingList({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        6,
        (index) => Container(
          height: 88,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
            ),
          ),
        ),
      ),
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
          const Icon(Icons.inventory_2_outlined, size: 44, color: AppTheme.textSecondary),
          const SizedBox(height: 10),
          Text(
            'No products yet',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'This storefront is still getting stocked.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
          ),
        ],
      ),
    );
  }
}
