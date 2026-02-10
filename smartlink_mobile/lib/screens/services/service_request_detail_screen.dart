import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/address_provider.dart';
import '../../providers/service_requests_provider.dart';
import '../../providers/services_provider.dart';
import '../../providers/wallet_provider.dart';
import '../addresses/address_list_screen.dart';
import '../security/pin_prompt.dart';

class ServiceRequestDetailScreen extends StatelessWidget {
  final String requestId;
  const ServiceRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final req = context.watch<ServiceRequestsProvider>().byId(requestId);
    if (req == null) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        appBar: AppBar(title: const Text('Request')),
        body: Center(
          child: Text(
            'Request not found.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    final service = context.watch<ServicesProvider>().byId(req.serviceId);
    final address = context.watch<AddressProvider>().defaultAddress;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Request')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _HeaderCard(request: req, serviceTitle: service?.title ?? 'Service'),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              AppRouter.addresses,
              arguments: const AddressListArgs(selectionMode: true),
            ),
            borderRadius: BorderRadius.circular(18),
            child: _Card(
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
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address?.addressText ?? 'Add/select an address',
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
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  req.requestText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _Pill(icon: Icons.bolt_outlined, label: req.urgency == 'urgent' ? 'Urgent' : 'Normal'),
                    const SizedBox(width: 10),
                    if (req.preferredDate != null)
                      _Pill(
                        icon: Icons.calendar_today_outlined,
                        label: '${req.preferredDate!.day}/${req.preferredDate!.month}/${req.preferredDate!.year}',
                      ),
                    if ((req.preferredTimeWindow?.isNotEmpty ?? false)) ...[
                      const SizedBox(width: 10),
                      _Pill(icon: Icons.schedule_outlined, label: req.preferredTimeWindow!),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _QuoteCard(request: req),
          const SizedBox(height: 12),
          _ContactCard(request: req),
          const SizedBox(height: 12),
          _TimelineCard(request: req),
          const SizedBox(height: 16),
          _Actions(request: req),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ServiceRequest request;
  final String serviceTitle;
  const _HeaderCard({required this.request, required this.serviceTitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, color) = _statusLabel(request.status);

    return Container(
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
          Row(
            children: [
              Expanded(
                child: Text(
                  serviceTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Request ${request.id}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            Formatting.shortDateTime(request.createdAt),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  final ServiceRequest request;
  const _QuoteCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quote = request.latestQuote;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quote',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (quote == null)
            Text(
              'Waiting for provider quote.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
            )
          else ...[
            Row(
              children: [
                Text(
                  Formatting.naira(quote.amount, decimalDigits: 0),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                Text(
                  Formatting.shortDateTime(quote.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              quote.note,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54, height: 1.35),
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final ServiceRequest request;
  const _ContactCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            request.contactUnlocked ? Icons.lock_open_outlined : Icons.lock_outline,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              request.contactUnlocked
                  ? 'Contact unlocked: ${request.contactToken ?? 'token'}'
                  : 'Contact is locked until payment is held.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final ServiceRequest request;
  const _TimelineCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const steps = [
      ServiceRequestStatus.submitted,
      ServiceRequestStatus.accepted,
      ServiceRequestStatus.awaitingCustomerApproval,
      ServiceRequestStatus.approved,
      ServiceRequestStatus.paymentHeld,
      ServiceRequestStatus.scheduled,
      ServiceRequestStatus.providerOnTheWay,
      ServiceRequestStatus.workStarted,
      ServiceRequestStatus.workCompletedProvider,
      ServiceRequestStatus.awaitingCustomerConfirmation,
      ServiceRequestStatus.completed,
    ];

    int indexOf(ServiceRequestStatus s) => steps.indexWhere((e) => e == s);
    final current = indexOf(request.status);

    return Container(
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
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          ...List.generate(steps.length, (i) {
            final s = steps[i];
            final done = current >= i && current != -1;
            final isCurrent = current == i;
            return _TimelineRow(
              title: _statusLabel(s).$1,
              isDone: done,
              isCurrent: isCurrent,
              isLast: i == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final ServiceRequest request;
  const _Actions({required this.request});

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<WalletProvider>();
    final quote = request.latestQuote;
    final serviceRequests = context.read<ServiceRequestsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final canAcceptQuote = request.status == ServiceRequestStatus.awaitingCustomerApproval && quote != null;
    final canPay = request.status == ServiceRequestStatus.approved && quote != null;
    final canConfirm = request.status == ServiceRequestStatus.awaitingCustomerConfirmation;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.read<ServiceRequestsProvider>().advance(request.id),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Simulate status'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: canAcceptQuote ? () => context.read<ServiceRequestsProvider>().customerAcceptQuote(request.id) : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Accept quote'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
                ElevatedButton(
          onPressed: canPay
              ? () async {
                  final amount = quote.amount.toDouble();
                  if (wallet.balance < amount) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Insufficient wallet balance. Please top up.')),
                    );
                    return;
                  }

                  final ok = await PinPrompt.verify(
                    context,
                    reason: 'Confirm payment hold in escrow for this service request.',
                  );
                  if (!ok) return;

                  final token = 'ct_${Random().nextInt(999999).toString().padLeft(6, '0')}';
                  await wallet.holdInEscrow(request.id, amount);
                  await serviceRequests.payHeld(request.id, contactToken: token);
                  if (!context.mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Payment held in escrow. Contact unlocked.')),
                  );
                }
              : null,
          child: Text(
            canPay ? 'Pay (hold in escrow)' : 'Pay',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: canConfirm
              ? () async {
                  await serviceRequests.advance(request.id);
                  await wallet.releaseEscrow(request.id);
                  if (!context.mounted) return;
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Completed. Escrow released.')),
                  );
                }
              : null,
          child: const Text('Confirm completion'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () async {
            await serviceRequests.advance(request.id);
            if (!context.mounted) return;
            messenger.showSnackBar(
              const SnackBar(content: Text('Issue reported. Escrow is frozen.')),
            );
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFF59E0B)),
            foregroundColor: const Color(0xFFF59E0B),
          ),
          child: const Text('Report issue'),
        ),
      ],
    );
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
              child: isDone ? const Icon(Icons.check, size: 12, color: AppTheme.primaryColor) : null,
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

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
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
      child: child,
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

(String, Color) _statusLabel(ServiceRequestStatus status) {
  return switch (status) {
    ServiceRequestStatus.submitted => ('Submitted', const Color(0xFF64748B)),
    ServiceRequestStatus.accepted => ('Accepted', const Color(0xFF2563EB)),
    ServiceRequestStatus.quoteSent => ('Quote sent', const Color(0xFF7C3AED)),
    ServiceRequestStatus.awaitingCustomerApproval => ('Approve quote', const Color(0xFFF59E0B)),
    ServiceRequestStatus.approved => ('Approved', const Color(0xFF16A34A)),
    ServiceRequestStatus.paymentHeld => ('Payment held', const Color(0xFF16A34A)),
    ServiceRequestStatus.scheduled => ('Scheduled', const Color(0xFF0EA5E9)),
    ServiceRequestStatus.providerOnTheWay => ('On the way', const Color(0xFF0EA5E9)),
    ServiceRequestStatus.workStarted => ('Work started', const Color(0xFFF97316)),
    ServiceRequestStatus.workCompletedProvider => ('Work completed', const Color(0xFF0F766E)),
    ServiceRequestStatus.awaitingCustomerConfirmation => ('Confirm completion', const Color(0xFFF59E0B)),
    ServiceRequestStatus.completed => ('Completed', const Color(0xFF16A34A)),
    ServiceRequestStatus.cancelled => ('Cancelled', const Color(0xFFDC2626)),
    ServiceRequestStatus.issueReported => ('Issue reported', const Color(0xFFB45309)),
    ServiceRequestStatus.disputed => ('Disputed', const Color(0xFFB45309)),
    ServiceRequestStatus.refunded => ('Refunded', const Color(0xFFDC2626)),
  };
}
