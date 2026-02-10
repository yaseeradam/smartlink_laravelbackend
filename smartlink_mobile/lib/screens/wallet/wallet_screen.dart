import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/wallet_card.dart';
import '../../widgets/common/fade_in_slide.dart';
import '../../widgets/common/smooth_button.dart';
import '../../widgets/common/gradient_background.dart';
import '../security/pin_prompt.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  Future<void> _promptAmount(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required Future<void> Function(double amount) action,
    required String pinReason,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final amount = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                    validator: (value) {
                      final v = double.tryParse((value ?? '').trim());
                      if (v == null || v <= 0) return 'Enter a valid amount';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      Navigator.pop(context, double.parse(controller.text.trim()));
                    },
                    child: Text(actionLabel),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),
        );
      },
    );

    controller.dispose();
    if (amount == null) return;
    if (!context.mounted) return;

    try {
      final ok = await PinPrompt.verify(context, reason: pinReason);
      if (!ok) return;
      if (!context.mounted) return;
      await action(amount);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('$actionLabel successful')),
      );
    } catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = context.watch<WalletProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Wallet')),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLg + 4),
          children: [
            FadeInSlide(
              delay: const Duration(milliseconds: 100),
              child: WalletCard(
                balance: wallet.balance,
                onTap: () {
                  Navigator.pushNamed(context, '/wallet/transactions');
                },
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            if (!auth.isPhoneVerified)
              FadeInSlide(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spaceMd + 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        const Color(0xFFF59E0B).withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spaceSm),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceMd),
                      Expanded(
                        child: Text(
                          'Verify your phone to unlock wallet access.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black87,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: AppTheme.spaceLg),
            FadeInSlide(
              delay: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(
                    child: SmoothButton(
                      text: 'Top up',
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: auth.isPhoneVerified
                          ? () => _promptAmount(
                                context,
                                title: 'Top up',
                                actionLabel: 'Top up',
                                action: wallet.topUp,
                                pinReason: 'Confirm top up to your SmartLink wallet.',
                              )
                          : null,
                      style: SmoothButtonStyle.primary,
                      isFullWidth: true,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: SmoothButton(
                      text: 'Withdraw',
                      icon: Icons.arrow_circle_down_outlined,
                      onPressed: auth.isPhoneVerified
                          ? () => _promptAmount(
                                context,
                                title: 'Withdraw',
                                actionLabel: 'Withdraw',
                                action: wallet.withdraw,
                                pinReason: 'Confirm wallet withdrawal.',
                              )
                          : null,
                      style: SmoothButtonStyle.secondary,
                      isFullWidth: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.space2Xl),
            FadeInSlide(
              delay: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceXs),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Text(
                    'Escrow holds',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            if (wallet.escrowHolds.isEmpty)
              FadeInSlide(
                delay: const Duration(milliseconds: 500),
                child: _EmptyCard(
                  text: 'No active escrow holds.',
                  isDark: isDark,
                  icon: Icons.lock_outline,
                ),
              )
            else
              ...wallet.escrowHolds.asMap().entries.map((entry) {
                final index = entry.key;
                final e = entry.value;
                final amount = (e['amount'] as num?)?.toDouble() ?? 0.0;
                final orderId = (e['orderId'] as String?) ?? '';
                final status = (e['status'] as String?) ?? 'held';
                return FadeInSlide(
                  delay: Duration(milliseconds: 500 + (index * 50)),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                    padding: const EdgeInsets.all(AppTheme.spaceMd + 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
                      ),
                      boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spaceSm),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withValues(alpha: 0.15),
                                AppTheme.primaryColor.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Formatting.naira(amount, decimalDigits: 0),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Order $orderId - $status',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: AppTheme.space2Xl),
            FadeInSlide(
              delay: Duration(milliseconds: 600 + (wallet.escrowHolds.length * 50)),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceXs),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Text(
                    'Transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/wallet/transactions');
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),
          if (wallet.transactions.isEmpty)
            _EmptyCard(
              text: 'No transactions yet.',
              isDark: isDark,
              icon: Icons.receipt_long_outlined,
            )
          else
            ...wallet.transactions.map((t) {
              final amount = (t['amount'] as num?)?.toDouble() ?? 0.0;
              final type = (t['type'] as String?) ?? '';
              final date = t['date'] is DateTime ? t['date'] as DateTime : DateTime.now();
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      type == 'topup' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: type == 'topup' ? AppTheme.primaryColor : const Color(0xFFDC2626),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type == 'topup' ? 'Top up' : 'Withdrawal',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatting.shortDateTime(date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      Formatting.naira(amount, decimalDigits: 0),
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: type == 'topup' ? AppTheme.primaryColor : const Color(0xFFDC2626),
                          ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),
        ],
      ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;
  final bool isDark;
  final IconData icon;
  const _EmptyCard({required this.text, required this.isDark, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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
