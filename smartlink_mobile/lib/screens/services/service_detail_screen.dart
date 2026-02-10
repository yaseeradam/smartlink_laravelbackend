import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/services_provider.dart';
import 'service_request_create_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final int serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final service = context.watch<ServicesProvider>().byId(serviceId);

    if (service == null) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        appBar: AppBar(title: const Text('Service')),
        body: Center(
          child: Text(
            'Service not found.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      );
    }

    final merchant = service.merchant;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Service')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.storefront_outlined, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            merchant.fullName,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            merchant.trusted ? 'Trusted provider' : 'Provider',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: merchant.trusted
                                      ? AppTheme.primaryColor
                                      : (isDark ? Colors.white70 : Colors.black54),
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (merchant.ratingAvg != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              merchant.ratingAvg!.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                    'Privacy first: contact + full address are locked until payment is held.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ServiceRequestCreateScreen(serviceId: service.id)),
            ),
            icon: const Icon(Icons.request_quote_outlined),
            label: const Text('Request a quote'),
          ),
        ],
      ),
    );
  }
}

