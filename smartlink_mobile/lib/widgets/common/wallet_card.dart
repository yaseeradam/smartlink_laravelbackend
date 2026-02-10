import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';

class WalletCard extends StatelessWidget {
  final double balance;
  final VoidCallback? onTap;

  const WalletCard({
    super.key,
    required this.balance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadows = isDark ? AppTheme.largeShadowDark : AppTheme.largeShadowLight;
    final textMain = isDark ? Colors.white : AppTheme.textMain;
    final textSub = isDark ? Colors.white70 : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    AppTheme.surfaceDark,
                    const Color(0xFF1F2937),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.white,
                    const Color(0xFFF9FAFB),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(
            color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
            width: 1,
          ),
          boxShadow: shadows,
        ),
        child: Stack(
          children: [
            // Decorative circles for depth
            Positioned(
              right: -50,
              top: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                      AppTheme.primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: -70,
              bottom: -90,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: isDark ? 0.05 : 0.03),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Wallet icon with gradient background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: isDark ? 0.25 : 0.15),
                            AppTheme.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceMd),
                    Expanded(
                      child: Text(
                        'SmartLink Wallet',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: textMain,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    // Escrow badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spaceMd,
                        vertical: AppTheme.spaceXs + 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.12),
                            AppTheme.primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: AppTheme.spaceXs),
                          Text(
                            'Escrow',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceLg),
                Text(
                  'Available balance',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textSub,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                // Balance with gradient text effect
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: isDark
                        ? [Colors.white, Colors.white70]
                        : [AppTheme.textMain, AppTheme.textMain.withValues(alpha: 0.8)],
                  ).createShader(bounds),
                  child: Text(
                    Formatting.naira(balance, decimalDigits: 2),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          height: 1.2,
                        ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                // Security info with soft background
                Container(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black)
                        .withValues(alpha: isDark ? 0.05 : 0.03),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 18,
                        color: textSub,
                      ),
                      const SizedBox(width: AppTheme.spaceSm),
                      Expanded(
                        child: Text(
                          'Protected payments held until you confirm delivery.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: textSub,
                                height: 1.4,
                              ),
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
    );
  }
}
