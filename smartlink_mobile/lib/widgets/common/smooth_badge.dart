import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A smooth badge with gradient background
class SmoothBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  final bool outlined;
  final EdgeInsetsGeometry? padding;

  const SmoothBadge({
    super.key,
    required this.text,
    this.icon,
    this.color,
    this.outlined = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final badgeColor = color ?? AppTheme.primaryColor;

    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: icon != null ? AppTheme.spaceSm : AppTheme.spaceMd,
            vertical: AppTheme.spaceXs,
          ),
      decoration: outlined
          ? BoxDecoration(
              border: Border.all(color: badgeColor, width: 1.5),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            )
          : BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  badgeColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  badgeColor.withValues(alpha: isDark ? 0.15 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: outlined ? badgeColor : badgeColor,
            ),
            const SizedBox(width: AppTheme.spaceXs),
          ],
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: outlined ? badgeColor : badgeColor,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
