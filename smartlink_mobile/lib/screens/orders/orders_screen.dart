import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orders = context.watch<OrdersProvider>().orders;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Orders')),
      body: orders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 56,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No orders yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your protected orders will show up here.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = orders[index];
                return InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.orderTracking,
                    arguments: order.id,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
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
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.shopName,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            _StatusPill(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              Formatting.shortDateTime(order.createdAt),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                            ),
                            Text(
                              '${order.itemCount} items',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Text(
                              Formatting.naira(order.total, decimalDigits: 0),
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final SmartlinkOrderStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      SmartlinkOrderStatus.placed => ('Placed', const Color(0xFF64748B)),
      SmartlinkOrderStatus.paid => ('Paid', const Color(0xFF16A34A)),
      SmartlinkOrderStatus.acceptedBySeller => ('Accepted', const Color(0xFF2563EB)),
      SmartlinkOrderStatus.dispatching => ('Dispatching', const Color(0xFF7C3AED)),
      SmartlinkOrderStatus.assignedToRider => ('Assigned', const Color(0xFF0EA5E9)),
      SmartlinkOrderStatus.pickedUp => ('Picked up', const Color(0xFFF97316)),
      SmartlinkOrderStatus.delivered => ('Delivered', const Color(0xFF0F766E)),
      SmartlinkOrderStatus.confirmed => ('Confirmed', const Color(0xFF16A34A)),
      SmartlinkOrderStatus.cancelled => ('Cancelled', const Color(0xFFDC2626)),
      SmartlinkOrderStatus.disputed => ('Disputed', const Color(0xFFB45309)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
