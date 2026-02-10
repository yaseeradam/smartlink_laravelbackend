import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class SellerWithdrawalsScreen extends StatefulWidget {
  const SellerWithdrawalsScreen({super.key});

  @override
  State<SellerWithdrawalsScreen> createState() => _SellerWithdrawalsScreenState();
}

class _SellerWithdrawalsScreenState extends State<SellerWithdrawalsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  List<Map<String, dynamic>> _methods = const [];

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
      final withdrawalsRes = await ApiClient.instance.getJson('seller/withdrawals');
      final methodsRes = await ApiClient.instance.getJson('seller/withdrawal-methods');
      final raw = (withdrawalsRes['data'] as List?) ?? const [];
      final items = raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      final methodsRaw = (methodsRes['methods'] as List?) ?? const [];
      final methods = methodsRaw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _items = items;
        _methods = methods;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openWithdrawalDialog() async {
    final amountController = TextEditingController();
    final pinController = TextEditingController();
    String method = _methods.isNotEmpty ? (_methods.first['key'] as String? ?? 'bank') : 'bank';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Request withdrawal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: method,
                      items: _methods
                          .map(
                            (m) => DropdownMenuItem<String>(
                              value: m['key'] as String?,
                              child: Text((m['label'] as String?) ?? 'Method'),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setDialogState(() => method = value ?? method),
                      decoration: const InputDecoration(labelText: 'Method'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Transaction PIN (if set)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text.trim());
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid amount.')),
                      );
                      return;
                    }
                    try {
                      await ApiClient.instance.postJson(
                        'seller/withdrawals',
                        body: {
                          'amount': amount,
                          'method': method,
                          'pin': pinController.text.trim().isEmpty ? null : pinController.text.trim(),
                        },
                      );
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    amountController.dispose();
    pinController.dispose();

    if (result == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    if (role != AppRole.merchant) {
      return const _NotAuthorizedScreen(title: 'Withdrawals');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Withdrawals')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null && _items.isEmpty) _EmptyCard(isDark: isDark, message: 'No withdrawals yet.'),
            if (!_loading && _error == null)
              ..._items.map((w) {
                final id = w['id'];
                final status = (w['status'] as String?) ?? '';
                final amount = (w['amount'] as String?) ?? '0';
                final createdAt = (w['created_at'] as String?) ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: outline),
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
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
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
            const SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: _openWithdrawalDialog,
              icon: const Icon(Icons.add),
              label: const Text('Request withdrawal'),
            ),
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
            'Could not load withdrawals',
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
          Icon(Icons.payments_outlined, color: isDark ? Colors.white54 : Colors.black45),
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
