import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/shimmer_box.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final title = (widget.product['title'] as String?) ?? '';
    final description = (widget.product['description'] as String?) ?? '';
    final price = (widget.product['price'] as num?)?.toDouble() ?? 0.0;
    final sellerName = (widget.product['sellerName'] as String?) ?? '';
    final sellerLocation = (widget.product['sellerLocation'] as String?) ?? '';
    final rating = (widget.product['rating'] as num?)?.toDouble() ?? 0.0;
    final reviewCount = (widget.product['reviewCount'] as num?)?.toInt() ?? 0;
    final stockQty = (widget.product['stockQuantity'] as num?)?.toInt() ?? 0;
    final isAvailable = (widget.product['isAvailable'] as bool?) ?? true;

    final images = (widget.product['images'] is List)
        ? (widget.product['images'] as List).cast<String>()
        : <String>[];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Expanded(
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
                        child: SizedBox(
                          height: 260,
                          child: Stack(
                            children: [
                              PageView.builder(
                                itemCount: images.isEmpty ? 1 : images.length,
                                onPageChanged: (i) => setState(() => _imageIndex = i),
                                itemBuilder: (context, index) {
                                  if (images.isEmpty) {
                                    return Container(
                                      color: isDark
                                          ? const Color(0xFF374151)
                                          : const Color(0xFFE5E7EB),
                                      child: const Center(
                                        child: Icon(Icons.image_outlined, size: 48),
                                      ),
                                    );
                                  }
                                   return CachedNetworkImage(
                                     imageUrl: images[index],
                                     fit: BoxFit.cover,
                                     placeholder: (_, __) => const ShimmerBox(
                                       height: 260,
                                       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                                     ),
                                     errorWidget: (_, __, ___) => Container(
                                       color: isDark
                                           ? const Color(0xFF374151)
                                           : const Color(0xFFE5E7EB),
                                      child: const Center(
                                        child: Icon(Icons.broken_image_outlined, size: 48),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Positioned(
                                left: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '${(_imageIndex + 1).clamp(1, images.isEmpty ? 1 : images.length)} / ${images.isEmpty ? 1 : images.length}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  Formatting.naira(price, decimalDigits: 0),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(width: 12),
                                _Pill(icon: Icons.star, label: '${rating.toStringAsFixed(1)} ($reviewCount)'),
                                const SizedBox(width: 8),
                                _Pill(
                                  icon: Icons.inventory_2_outlined,
                                  label: isAvailable ? '$stockQty in stock' : 'Unavailable',
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'About',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    height: 1.45,
                                  ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.storefront_outlined, color: AppTheme.primaryColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sellerName,
                                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          sellerLocation,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Protected Payment: your money stays in escrow until you confirm delivery.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black87,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isAvailable
                          ? () {
                              context.read<CartProvider>().addItem(widget.product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart')),
                              );
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.6)),
                      ),
                      child: const Text('Add to cart'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isAvailable
                          ? () {
                              context.read<CartProvider>().addItem(widget.product);
                              Navigator.pushNamed(context, AppRouter.cart);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Buy now'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
