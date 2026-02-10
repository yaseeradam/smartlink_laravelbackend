import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/kyc_provider.dart';
import 'kyc_submit_screen.dart';

class KycStatusScreen extends StatelessWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<KycProvider>();
    final loaded = provider.isLoaded;
    final requests = provider.requests;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Verification (KYC)'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KycSubmitScreen()),
            ),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                      const Icon(Icons.verified_user_outlined, color: AppTheme.primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Verification helps keep SmartLink safe and unlocks seller/rider features.',
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
                if (requests.isEmpty)
                  _Empty(isDark: isDark)
                else
                  ...requests.map((r) => _RequestCard(request: r)),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KycSubmitScreen()),
                  ),
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Submit new KYC'),
                ),
              ],
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  final bool isDark;
  const _Empty({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        children: [
          Icon(Icons.shield_outlined, size: 48, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(height: 10),
          Text(
            'No submissions yet',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Submit verification when you’re ready.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final SmartlinkKycRequest request;
  const _RequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (label, color) = switch (request.status) {
      SmartlinkKycStatus.pending => ('Pending review', const Color(0xFFF59E0B)),
      SmartlinkKycStatus.approved => ('Approved', const Color(0xFF16A34A)),
      SmartlinkKycStatus.rejected => ('Rejected', const Color(0xFFDC2626)),
    };

    final typeLabel = switch (request.type) {
      SmartlinkKycType.buyerBasic => 'Buyer basic',
      SmartlinkKycType.seller => 'Seller',
      SmartlinkKycType.rider => 'Rider',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  typeLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
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
            'Submitted ${Formatting.shortDateTime(request.submittedAt)} • ${request.documents.length} docs',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
          ),
          if (request.status == SmartlinkKycStatus.rejected &&
              (request.rejectionReason?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            Text(
              request.rejectionReason!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFDC2626),
                    height: 1.35,
                  ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context
                      .read<KycProvider>()
                      .simulateAdminDecision(request.id, SmartlinkKycStatus.approved),
                  child: const Text('Simulate approve'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context
                      .read<KycProvider>()
                      .simulateAdminDecision(request.id, SmartlinkKycStatus.rejected),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    foregroundColor: const Color(0xFFDC2626),
                  ),
                  child: const Text('Simulate reject'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

