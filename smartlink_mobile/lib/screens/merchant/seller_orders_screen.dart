import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';
import 'seller_order_detail_screen.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

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
      final res = await ApiClient.instance.getJson('seller/orders');
      final raw = (res['data'] as List?) ?? const [];
      final items = raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      if (!mounted) return;
      setState(() => _items = items);
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
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    if (role != AppRole.merchant) {
      return const _NotAuthorizedScreen(title: 'Seller orders');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Orders')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null && _items.isEmpty) _EmptyCard(isDark: isDark, message: 'No orders yet.'),
            if (!_loading && _error == null)
              ..._items.map((o) {
                final id = o['id'];
                final status = (o['status'] as String?) ?? '';
                final total = (o['total_amount'] as String?) ?? '';
                final createdAt = (o['created_at'] as String?) ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: outline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: id == null
                          ? null
                          : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SellerOrderDetailScreen(orderId: id),
                                ),
                              ),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryColor),
                      ),
                      title: Text(
                        id == null ? 'Order' : 'Order #$id',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        [
                          if (status.trim().isNotEmpty) status.trim(),
                          if (total.trim().isNotEmpty) 'Total: $total',
                          if (createdAt.trim().isNotEmpty) createdAt.trim(),
                        ].join(' | '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                );
              }),
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
            'Could not load orders',
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
          Icon(Icons.receipt_long_outlined, color: isDark ? Colors.white54 : Colors.black45),
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

class _NotAuthorizedScreen extends StatelessWidget {
  final String title;
  const _NotAuthorizedScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Not authorized for this section.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
