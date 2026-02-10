import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A smooth section divider with optional title
class SectionDivider extends StatelessWidget {
  final String? title;
  final EdgeInsetsGeometry? margin;
  final bool showLine;

  const SectionDivider({
    super.key,
    this.title,
    this.margin,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    if (title == null && showLine) {
      return Container(
        margin: margin ?? const EdgeInsets.symmetric(vertical: AppTheme.spaceLg),
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              dividerColor.withValues(alpha: 0),
              dividerColor,
              dividerColor.withValues(alpha: 0),
            ],
          ),
        ),
      );
    }

    if (title != null) {
      return Container(
        margin: margin ?? const EdgeInsets.symmetric(vertical: AppTheme.spaceLg),
        child: Row(
          children: [
            if (showLine) ...[
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        dividerColor.withValues(alpha: 0),
                        dividerColor,
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
            ],
            Text(
              title!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (showLine) ...[
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        dividerColor,
                        dividerColor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
