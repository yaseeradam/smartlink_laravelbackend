import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class SellerOrderDetailScreen extends StatefulWidget {
  final Object orderId;
  const SellerOrderDetailScreen({super.key, required this.orderId});

  @override
  State<SellerOrderDetailScreen> createState() => _SellerOrderDetailScreenState();
}

class _SellerOrderDetailScreenState extends State<SellerOrderDetailScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _order;

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
      final res = await ApiClient.instance.getJson('orders/${widget.orderId}');
      if (!mounted) return;
      setState(() => _order = res['data'] is Map ? (res['data'] as Map).cast<String, dynamic>() : res);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _startWorkflow() async {
    final etaMinController = TextEditingController();
    final etaMaxController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start workflow'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: etaMinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ETA min (minutes)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: etaMaxController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ETA max (minutes)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Start')),
          ],
        );
      },
    );

    final etaMin = int.tryParse(etaMinController.text.trim());
    final etaMax = int.tryParse(etaMaxController.text.trim());
    etaMinController.dispose();
    etaMaxController.dispose();

    if (result != true) return;

    try {
      await ApiClient.instance.postJson(
        'seller/orders/${widget.orderId}/workflow/start',
        body: {
          if (etaMin != null) 'eta_min': etaMin,
          if (etaMax != null) 'eta_max': etaMax,
        },
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _advanceWorkflow() async {
    try {
      final res = await ApiClient.instance.getJson('seller/orders/${widget.orderId}/workflow/next-steps');
      final raw = (res['data'] as List?) ?? const [];
      final steps = raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      if (steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No next steps.')));
        return;
      }

      String? stepKey = steps.first['step_key'] as String?;
      final etaMinController = TextEditingController();
      final etaMaxController = TextEditingController();

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Advance workflow'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: stepKey,
                      items: steps
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s['step_key'] as String?,
                              child: Text((s['title'] as String?) ?? (s['step_key'] as String?) ?? 'Step'),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setDialogState(() => stepKey = value),
                      decoration: const InputDecoration(labelText: 'Next step'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: etaMinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ETA min (minutes)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: etaMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ETA max (minutes)'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Advance')),
                ],
              );
            },
          );
        },
      );

      final etaMin = int.tryParse(etaMinController.text.trim());
      final etaMax = int.tryParse(etaMaxController.text.trim());
      etaMinController.dispose();
      etaMaxController.dispose();

      if (confirm != true || stepKey == null) return;

      await ApiClient.instance.postJson(
        'seller/orders/${widget.orderId}/workflow/advance',
        body: {
          'to_step_key': stepKey,
          if (etaMin != null) 'eta_min': etaMin,
          if (etaMax != null) 'eta_max': etaMax,
        },
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _createShipment() async {
    final courierController = TextEditingController();
    final feeController = TextEditingController();
    final etaMinController = TextEditingController();
    final etaMaxController = TextEditingController();
    String shippingType = 'seller_handled';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create shipment'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: shippingType,
                      items: const [
                        DropdownMenuItem(value: 'seller_handled', child: Text('Seller handled')),
                        DropdownMenuItem(value: 'partner', child: Text('Partner')),
                      ],
                      onChanged: (value) => setDialogState(() => shippingType = value ?? shippingType),
                      decoration: const InputDecoration(labelText: 'Shipping type'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: courierController,
                      decoration: const InputDecoration(labelText: 'Courier name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: feeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Shipping fee'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: etaMinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ETA min (days)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: etaMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'ETA max (days)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
              ],
            );
          },
        );
      },
    );

    final fee = double.tryParse(feeController.text.trim());
    final etaMin = int.tryParse(etaMinController.text.trim());
    final etaMax = int.tryParse(etaMaxController.text.trim());
    final courier = courierController.text.trim();
    courierController.dispose();
    feeController.dispose();
    etaMinController.dispose();
    etaMaxController.dispose();

    if (result != true) return;
    if (courier.isEmpty || fee == null || etaMin == null || etaMax == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill in all fields.')));
      return;
    }

    try {
      await ApiClient.instance.postJson(
        'seller/orders/${widget.orderId}/shipping/create',
        body: {
          'shipping_type': shippingType,
          'courier_name': courier,
          'shipping_fee': fee,
          'eta_days_min': etaMin,
          'eta_days_max': etaMax,
        },
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _dispatchRider() async {
    try {
      await ApiClient.instance.postJson('orders/${widget.orderId}/dispatch');
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    if (role != AppRole.merchant) {
      return const _NotAuthorizedScreen(title: 'Order');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;
    final status = (_order?['status'] as String?) ?? '';
    final total = (_order?['total_amount'] as String?) ?? '';
    final workflowState = (_order?['workflow_state'] as String?) ?? '';
    final paymentStatus = (_order?['payment_status'] as String?) ?? '';

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text('Order ${widget.orderId}')),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Status', value: status),
                  _SummaryRow(label: 'Payment', value: paymentStatus),
                  _SummaryRow(label: 'Workflow', value: workflowState),
                  _SummaryRow(label: 'Total', value: total),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null)
              Column(
                children: [
                  _Action(
                    title: 'Start workflow',
                    subtitle: 'POST /seller/orders/{order}/workflow/start',
                    icon: Icons.play_circle_outline,
                    outline: outline,
                    isDark: isDark,
                    onTap: _startWorkflow,
                  ),
                  const SizedBox(height: 12),
                  _Action(
                    title: 'Advance workflow',
                    subtitle: 'POST /seller/orders/{order}/workflow/advance',
                    icon: Icons.fast_forward_outlined,
                    outline: outline,
                    isDark: isDark,
                    onTap: _advanceWorkflow,
                  ),
                  const SizedBox(height: 12),
                  _Action(
                    title: 'Create shipment',
                    subtitle: 'POST /seller/orders/{order}/shipping/create',
                    icon: Icons.inventory_2_outlined,
                    outline: outline,
                    isDark: isDark,
                    onTap: _createShipment,
                  ),
                  const SizedBox(height: 12),
                  _Action(
                    title: 'Dispatch rider',
                    subtitle: 'POST /orders/{order}/dispatch',
                    icon: Icons.two_wheeler_outlined,
                    outline: outline,
                    isDark: isDark,
                    onTap: _dispatchRider,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
          Text(
            value.isEmpty ? '-' : value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color outline;
  final bool isDark;
  final VoidCallback onTap;

  const _Action({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.outline,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: outline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppTheme.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: isDark ? Colors.white60 : Colors.black45),
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
            'Could not load order',
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
