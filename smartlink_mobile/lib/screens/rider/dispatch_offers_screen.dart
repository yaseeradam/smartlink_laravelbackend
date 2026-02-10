import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class DispatchOffersScreen extends StatefulWidget {
  const DispatchOffersScreen({super.key});

  @override
  State<DispatchOffersScreen> createState() => _DispatchOffersScreenState();
}

class _DispatchOffersScreenState extends State<DispatchOffersScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _offers = const [];

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
      final res = await ApiClient.instance.getJson('rider/dispatch/offers');
      final raw = (res['data'] as List?) ?? const [];
      final offers = raw
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(growable: false);
      if (!mounted) return;
      setState(() => _offers = offers);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _accept(int offerId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ApiClient.instance.postJson('rider/dispatch/offers/$offerId/accept');
      await _load();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Offer accepted.')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _decline(int offerId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ApiClient.instance.postJson('rider/dispatch/offers/$offerId/decline');
      await _load();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Offer declined.')));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    if (role != AppRole.rider) {
      return const _NotAuthorizedScreen(title: 'Dispatch Offers');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Dispatch Offers')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: AppTheme.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'New jobs appear here. Accepting assigns the dispatch to you.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black87,
                            height: 1.35,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              _ErrorCard(message: _error!, isDark: isDark, onRetry: _load)
            else if (_offers.isEmpty)
              _EmptyCard(isDark: isDark, message: 'No offers right now.')
            else
              ..._offers.map((offer) {
                final offerId = (offer['id'] as num?)?.toInt();
                final order = (offer['order'] is Map)
                    ? (offer['order'] as Map).cast<String, dynamic>()
                    : const <String, dynamic>{};
                final orderId = order['id'];
                final total = (order['total_amount'] as String?) ?? '';
                final address = (order['delivery_address_text'] as String?) ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Offer #${offerId ?? '—'} • Order $orderId',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [address, total.isEmpty ? null : 'Total ₦$total']
                                    .whereType<String>()
                                    .where((e) => e.trim().isNotEmpty)
                                    .join(' • '),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (offerId != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton(
                                onPressed: () => _decline(offerId),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark ? Colors.white70 : Colors.black87,
                                  side: BorderSide(color: outline),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                child: const Text('Decline'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _accept(offerId),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                child: const Text('Accept'),
                              ),
                            ],
                          ),
                      ],
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
            'Couldn’t load offers',
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
          Icon(Icons.inbox_outlined, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
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

