import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/orders_provider.dart';
import '../../providers/wallet_provider.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final order = context.watch<OrdersProvider>().byId(orderId);

    if (order == null) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        appBar: AppBar(title: const Text('Tracking')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Order not found.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      );
    }

    const steps = [
      SmartlinkOrderStatus.paid,
      SmartlinkOrderStatus.acceptedBySeller,
      SmartlinkOrderStatus.dispatching,
      SmartlinkOrderStatus.assignedToRider,
      SmartlinkOrderStatus.pickedUp,
      SmartlinkOrderStatus.delivered,
      SmartlinkOrderStatus.confirmed,
    ];

    int indexOf(SmartlinkOrderStatus s) => steps.indexWhere((e) => e == s);
    final currentIndex = indexOf(order.status);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Tracking')),
      body: ListView(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.shopName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Order $orderId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                ),
                const SizedBox(height: 12),
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
                      Formatting.naira(order.total, decimalDigits: 0),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timeline',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 12),
                ...List.generate(steps.length, (i) {
                  final step = steps[i];
                  final isDone = currentIndex >= i && currentIndex != -1;
                  final isCurrent = currentIndex == i;
                  return _TimelineRow(
                    title: _statusLabel(step),
                    isDone: isDone,
                    isCurrent: isCurrent,
                    isLast: i == steps.length - 1,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Protected Payment is active for this order. Escrow is released when you confirm delivery.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.read<OrdersProvider>().advanceStatus(orderId),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Simulate update'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: order.status == SmartlinkOrderStatus.delivered
                      ? () {
                          context.read<OrdersProvider>().setStatus(
                                orderId,
                                SmartlinkOrderStatus.confirmed,
                              );
                          context.read<WalletProvider>().releaseEscrow(orderId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Delivery confirmed. Escrow released.')),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.verified),
                  label: const Text('Confirm'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {
              context.read<OrdersProvider>().setStatus(orderId, SmartlinkOrderStatus.disputed);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dispute raised. Escrow is frozen.')),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: const BorderSide(color: Color(0xFFF59E0B)),
              foregroundColor: const Color(0xFFF59E0B),
            ),
            child: const Text('Raise dispute'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static String _statusLabel(SmartlinkOrderStatus status) {
    return switch (status) {
      SmartlinkOrderStatus.placed => 'Placed',
      SmartlinkOrderStatus.paid => 'Paid (escrow held)',
      SmartlinkOrderStatus.acceptedBySeller => 'Accepted by seller',
      SmartlinkOrderStatus.dispatching => 'Dispatching',
      SmartlinkOrderStatus.assignedToRider => 'Rider assigned',
      SmartlinkOrderStatus.pickedUp => 'Picked up',
      SmartlinkOrderStatus.delivered => 'Delivered',
      SmartlinkOrderStatus.confirmed => 'Confirmed',
      SmartlinkOrderStatus.cancelled => 'Cancelled',
      SmartlinkOrderStatus.disputed => 'Disputed',
    };
  }
}

class _TimelineRow extends StatelessWidget {
  final String title;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;

  const _TimelineRow({
    required this.title,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = isDone ? AppTheme.primaryColor : const Color(0xFFD1D5DB);
    final dotColor = isDone
        ? AppTheme.primaryColor
        : (isCurrent ? const Color(0xFF10B981) : const Color(0xFF9CA3AF));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: dotColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 2),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 12, color: AppTheme.primaryColor)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: lineColor.withValues(alpha: 0.5),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
