import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/service_requests_provider.dart';
import '../../providers/services_provider.dart';
import 'service_request_detail_screen.dart';

class ServiceRequestsScreen extends StatelessWidget {
  const ServiceRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ServiceRequestsProvider>();
    final loaded = provider.isLoaded;
    final items = provider.items;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('My service requests')),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: isDark ? Colors.white54 : Colors.black45),
                        const SizedBox(height: 14),
                        Text(
                          'No requests yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Request a quote from a trusted provider.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ItemCard(request: items[index]),
                ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ServiceRequest request;
  const _ItemCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = context.watch<ServicesProvider>().byId(request.serviceId);

    final (label, color) = switch (request.status) {
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

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ServiceRequestDetailScreen(requestId: request.id)),
      ),
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
                    service?.title ?? 'Service request',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              Formatting.shortDateTime(request.createdAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
            ),
            const SizedBox(height: 10),
            if (request.latestQuote != null)
              Row(
                children: [
                  const Icon(Icons.request_quote_outlined, size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    Formatting.naira(request.latestQuote!.amount, decimalDigits: 0),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Spacer(),
                  if (request.contactUnlocked)
                    const Icon(Icons.lock_open_outlined, color: AppTheme.primaryColor),
                ],
              )
            else
              Text(
                'Waiting for quote',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

