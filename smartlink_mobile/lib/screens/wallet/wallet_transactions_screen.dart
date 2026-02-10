import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';

class WalletTransactionsScreen extends StatefulWidget {
  const WalletTransactionsScreen({super.key});

  @override
  State<WalletTransactionsScreen> createState() => _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
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
      final res = await ApiClient.instance.getJson('wallet/transactions');
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
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Wallet transactions')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null && _items.isEmpty) _EmptyCard(isDark: isDark, message: 'No transactions yet.'),
            if (!_loading && _error == null)
              ..._items.map((t) {
                final id = t['id'];
                final amount = double.tryParse((t['amount'] ?? '').toString()) ?? (t['amount'] as num?)?.toDouble() ?? 0.0;
                final direction = (t['direction'] as String?) ?? '';
                final type = (t['type'] as String?) ?? 'transaction';
                final status = (t['status'] as String?) ?? '';
                final createdAt = (t['created_at'] as String?) ?? '';

                final positive = direction.toLowerCase() == 'credit';
                final color = positive ? AppTheme.primaryColor : const Color(0xFFDC2626);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
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
                    onTap: id == null
                        ? null
                        : () => Navigator.pushNamed(
                              context,
                              AppRouter.walletTransaction,
                              arguments: id,
                            ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        positive ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                        color: color,
                      ),
                    ),
                    title: Text(
                      type,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text(
                      [status, createdAt].where((e) => e.trim().isNotEmpty).join(' • '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                    ),
                    trailing: Text(
                      Formatting.naira(amount, decimalDigits: 0),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: color,
                          ),
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
            'Couldn’t load transactions',
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

