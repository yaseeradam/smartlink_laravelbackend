import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/shimmer_box.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 56,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Your cart is empty',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add a few items from a nearby storefront.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continue shopping'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
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
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: CachedNetworkImage(
                                imageUrl: item.productImage,
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
                                  color: isDark
                                      ? const Color(0xFF374151)
                                      : const Color(0xFFE5E7EB),
                                  child: const Icon(Icons.image_outlined),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    Formatting.naira(item.price, decimalDigits: 0),
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                _QtyButton(
                                  icon: Icons.remove,
                                  onTap: () => context
                                      .read<CartProvider>()
                                      .updateQuantity(item.productId, item.quantity - 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Text(
                                    '${item.quantity}',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ),
                                _QtyButton(
                                  icon: Icons.add,
                                  onTap: () => context
                                      .read<CartProvider>()
                                      .updateQuantity(item.productId, item.quantity + 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
                  child: Column(
                    children: [
                      _Row(
                        label: 'Subtotal',
                        value: Formatting.naira(cart.subtotal, decimalDigits: 0),
                      ),
                      const SizedBox(height: 8),
                      _Row(
                        label: 'Delivery fee',
                        value: Formatting.naira(cart.deliveryFee, decimalDigits: 0),
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      _Row(
                        label: 'Total',
                        value: Formatting.naira(cart.total, decimalDigits: 0),
                        isStrong: true,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, AppRouter.checkout),
                        child: const Text('Continue to checkout'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isStrong;
  const _Row({required this.label, required this.value, this.isStrong = false});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: isStrong ? FontWeight.w900 : FontWeight.w700,
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
