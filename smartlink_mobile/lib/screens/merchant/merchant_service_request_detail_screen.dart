import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class MerchantServiceRequestDetailScreen extends StatefulWidget {
  final Object requestId;
  const MerchantServiceRequestDetailScreen({super.key, required this.requestId});

  @override
  State<MerchantServiceRequestDetailScreen> createState() => _MerchantServiceRequestDetailScreenState();
}

class _MerchantServiceRequestDetailScreenState extends State<MerchantServiceRequestDetailScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _request;

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
      final res = await ApiClient.instance.getJson('merchant/service-requests/${widget.requestId}');
      final data = res['data'] is Map ? (res['data'] as Map).cast<String, dynamic>() : res;
      if (!mounted) return;
      setState(() => _request = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _acceptRequest() async {
    try {
      await ApiClient.instance.postJson('merchant/service-requests/${widget.requestId}/accept');
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _sendQuote() async {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    final expiresController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send quote'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: expiresController,
                decoration: const InputDecoration(labelText: 'Expires at (YYYY-MM-DD)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Send')),
          ],
        );
      },
    );

    final amount = double.tryParse(amountController.text.trim());
    final notes = notesController.text.trim();
    final expiresAt = expiresController.text.trim();
    amountController.dispose();
    notesController.dispose();
    expiresController.dispose();

    if (confirm != true || amount == null) {
      return;
    }

    try {
      await ApiClient.instance.postJson(
        'merchant/service-requests/${widget.requestId}/send-quote',
        body: {
          'amount': amount,
          'notes': notes.isEmpty ? null : notes,
          'expires_at': expiresAt.isEmpty ? null : expiresAt,
        },
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _setStatus() async {
    String status = 'scheduled';
    final scheduledController = TextEditingController();
    final etaController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Set status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: status,
                    items: const [
                      DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                      DropdownMenuItem(value: 'provider_on_the_way', child: Text('Provider on the way')),
                      DropdownMenuItem(value: 'work_started', child: Text('Work started')),
                      DropdownMenuItem(value: 'work_completed_provider', child: Text('Work completed')),
                      DropdownMenuItem(value: 'awaiting_customer_confirmation', child: Text('Awaiting confirmation')),
                    ],
                    onChanged: (value) => setDialogState(() => status = value ?? status),
                    decoration: const InputDecoration(labelText: 'Status'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: scheduledController,
                    decoration: const InputDecoration(labelText: 'Scheduled at (YYYY-MM-DD)'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: etaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Arrival ETA (minutes)'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Update')),
              ],
            );
          },
        );
      },
    );

    final scheduledAt = scheduledController.text.trim();
    final eta = int.tryParse(etaController.text.trim());
    scheduledController.dispose();
    etaController.dispose();

    if (confirm != true) return;

    try {
      await ApiClient.instance.postJson(
        'merchant/service-requests/${widget.requestId}/set-status',
        body: {
          'status': status,
          if (scheduledAt.isNotEmpty) 'scheduled_at': scheduledAt,
          if (eta != null) 'arrival_eta_minutes': eta,
        },
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _cancelRequest() async {
    final reasonController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel request'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(labelText: 'Reason'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Dismiss')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel request')),
          ],
        );
      },
    );

    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (confirm != true) return;

    try {
      await ApiClient.instance.postJson(
        'merchant/service-requests/${widget.requestId}/cancel',
        body: {
          'reason': reason.isEmpty ? null : reason,
        },
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _openContact() async {
    try {
      final res = await ApiClient.instance.getJson('merchant/service-requests/${widget.requestId}/contact');
      final token = res['contact_token']?.toString() ?? '';
      final phone = res['customer_phone']?.toString() ?? '';
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Contact details'),
            content: Text(
              [
                if (token.isNotEmpty) 'Contact token: $token',
                if (phone.isNotEmpty) 'Customer phone: $phone',
              ].join('\n'),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _openDispute() async {
    try {
      final res = await ApiClient.instance.getJson('merchant/service-requests/${widget.requestId}/dispute');
      final data = res['data'];
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Dispute'),
            content: Text(data == null ? 'No dispute yet.' : data.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
            ],
          );
        },
      );
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
      return const _NotAuthorizedScreen(title: 'Service request');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;
    final status = (_request?['status'] as String?) ?? '';
    final requestText = (_request?['request_text'] as String?) ?? '';
    final createdAt = (_request?['created_at'] as String?) ?? '';
    final address = _request?['address'] as Map?;
    final addressText = [
      address?['state'],
      address?['city'],
    ].where((e) => e != null && e.toString().trim().isNotEmpty).join(', ');

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text('Request ${widget.requestId}')),
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
                    'Request summary',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      if (status.trim().isNotEmpty) 'Status: $status',
                      if (createdAt.trim().isNotEmpty) createdAt.trim(),
                      if (addressText.trim().isNotEmpty) addressText,
                    ].join(' | '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                  if (requestText.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      requestText.trim(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                    ),
                  ],
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
                    title: 'Accept request',
                    subtitle: 'POST /merchant/service-requests/{id}/accept',
                    icon: Icons.check_circle_outline,
                    outline: outline,
                    isDark: isDark,
                    onTap: _acceptRequest,
                  ),
                  const SizedBox(height: 12),
                  _Action(
                    title: 'Send quote',
                    subtitle: 'POST /merchant/service-requests/{id}/send-quote',
                    icon: Icons.request_quote_outlined,
                    outline: outline,
                    isDark: isDark,
                    onTap: _sendQuote,
                  ),
                  const SizedBox(height: 12),
                  _Action(
                    title: 'Set status',
                    subtitle: 'POST /merchant/service-requests/{id}/set-status',
                    icon: Icons.timelapse_outlined,
                    outline: outline,
                    isDark: isDark,
                    onTap: _setStatus,
                  ),
                  const SizedBox(height: 12),
                  _Action(
                    title: 'Contact customer',
                    subtitle: 'GET /merchant/service-requests/{id}/contact',
                    icon: Icons.call_outlined,
                    outline: outline,
                    isDark: isDark,
                    onTap: _openContact,
                  ),
                  const SizedBox(height: 12),
                  _Action(
                    title: 'Open dispute',
                    subtitle: 'GET /merchant/service-requests/{id}/dispute',
                    icon: Icons.gavel_outlined,
                    outline: outline,
                    isDark: isDark,
                    onTap: _openDispute,
                  ),
                  const SizedBox(height: 12),
                  _Action(
                    title: 'Cancel request',
                    subtitle: 'POST /merchant/service-requests/{id}/cancel',
                    icon: Icons.close_outlined,
                    outline: outline,
                    isDark: isDark,
                    onTap: _cancelRequest,
                  ),
                ],
              ),
          ],
        ),
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
            'Could not load request',
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
