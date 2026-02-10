import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _withdrawals = const [];

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
      final res = await ApiClient.instance.getJson('seller/earnings');
      final rawWithdrawals = res['withdrawals'];
      List<Map<String, dynamic>> items = const [];
      if (rawWithdrawals is Map && rawWithdrawals['data'] is List) {
        items = (rawWithdrawals['data'] as List)
            .whereType<Map>()
            .map((e) => e.cast<String, dynamic>())
            .toList(growable: false);
      } else if (rawWithdrawals is List) {
        items = rawWithdrawals.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      }
      if (!mounted) return;
      setState(() {
        _summary = res;
        _withdrawals = items;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _parseMoney(Object? raw) {
    return double.tryParse((raw ?? '0').toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    if (role != AppRole.merchant) {
      return const _NotAuthorizedScreen(title: 'Earnings');
    }

    final available = _parseMoney(_summary?['available_balance']);
    final held = _parseMoney(_summary?['held_in_escrow']);
    final total = available + held;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Earnings')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.payments_outlined, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your earnings',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track sales and payouts.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                                height: 1.35,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null)
              Column(
                children: [
                  _MetricRow(isDark: isDark, label: 'Available', value: available.toStringAsFixed(2)),
                  const SizedBox(height: 10),
                  _MetricRow(isDark: isDark, label: 'In escrow', value: held.toStringAsFixed(2)),
                  const SizedBox(height: 10),
                  _MetricRow(isDark: isDark, label: 'Total', value: total.toStringAsFixed(2)),
                ],
              ),
            const SizedBox(height: 18),
            if (!_loading && _error == null) _WithdrawalsList(items: _withdrawals, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalsList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final bool isDark;
  const _WithdrawalsList({required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyCard(isDark: isDark, message: 'No withdrawals yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent withdrawals',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...items.take(3).map((w) {
          final id = w['id'];
          final amount = (w['amount'] as String?) ?? '0';
          final status = (w['status'] as String?) ?? '';
          final createdAt = (w['created_at'] as String?) ?? '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: AppTheme.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      [
                        if (id != null) 'Withdrawal #$id',
                        if (status.trim().isNotEmpty) status.trim(),
                        if (createdAt.trim().isNotEmpty) createdAt.trim(),
                      ].join(' | '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                    ),
                  ),
                  Text(
                    amount,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final bool isDark;
  final String label;
  final String value;

  const _MetricRow({
    required this.isDark,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
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
            'Could not load earnings',
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
          Icon(Icons.wallet_outlined, color: isDark ? Colors.white54 : Colors.black45),
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
