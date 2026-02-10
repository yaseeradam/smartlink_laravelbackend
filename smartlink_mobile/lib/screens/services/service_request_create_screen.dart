import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../../providers/service_requests_provider.dart';
import '../../providers/services_provider.dart';
import '../addresses/address_list_screen.dart';
import 'service_request_detail_screen.dart';

class ServiceRequestCreateScreen extends StatefulWidget {
  final int serviceId;
  const ServiceRequestCreateScreen({super.key, required this.serviceId});

  @override
  State<ServiceRequestCreateScreen> createState() => _ServiceRequestCreateScreenState();
}

class _ServiceRequestCreateScreenState extends State<ServiceRequestCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requestController = TextEditingController();
  final _timeWindowController = TextEditingController();
  DateTime? _preferredDate;
  String _urgency = 'normal';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _requestController.dispose();
    _timeWindowController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 60)),
      initialDate: _preferredDate ?? now,
    );
    if (picked == null) return;
    setState(() => _preferredDate = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = context.read<AddressProvider>().defaultAddress;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a delivery address to continue.')),
      );
      await Navigator.pushNamed(
        context,
        AppRouter.addresses,
        arguments: const AddressListArgs(selectionMode: true),
      );
      if (!mounted) return;
      if (context.read<AddressProvider>().defaultAddress == null) return;
    }

    setState(() => _isSubmitting = true);
    try {
      final a = context.read<AddressProvider>().defaultAddress!;
      final req = await context.read<ServiceRequestsProvider>().submit(
            serviceId: widget.serviceId,
            addressLocalId: int.tryParse(a.id.replaceAll(RegExp(r'\\D'), '')) ?? 1,
            requestText: _requestController.text.trim(),
            preferredDate: _preferredDate,
            preferredTimeWindow: _timeWindowController.text.trim().isEmpty
                ? null
                : _timeWindowController.text.trim(),
            urgency: _urgency,
          );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ServiceRequestDetailScreen(requestId: req.id)),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = context.watch<ServicesProvider>().byId(widget.serviceId);
    final address = context.watch<AddressProvider>().defaultAddress;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Request a quote')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (service != null)
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
                    service.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    service.merchant.fullName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.addresses,
              arguments: const AddressListArgs(selectionMode: true),
            ),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Address',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address == null ? 'Add/select an address' : address.addressText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: address == null
                                    ? const Color(0xFFF59E0B)
                                    : (isDark ? Colors.white70 : Colors.black54),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _requestController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'What do you need?',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                    validator: (v) {
                      final text = v?.trim() ?? '';
                      if (text.length < 10) return 'Add a few details (min 10 chars)';
                      if (text.length > 5000) return 'Too long (max 5000 chars)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(_preferredDate == null
                              ? 'Preferred date'
                              : '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _timeWindowController,
                          decoration: const InputDecoration(
                            labelText: 'Time window (optional)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _urgency,
                    decoration: const InputDecoration(
                      labelText: 'Urgency',
                      prefixIcon: Icon(Icons.bolt_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                    ],
                    onChanged: (v) => setState(() => _urgency = v ?? 'normal'),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your full address and the provider phone stay locked until payment is held.',
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
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Text(_isSubmitting ? 'Submitting…' : 'Submit request'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

