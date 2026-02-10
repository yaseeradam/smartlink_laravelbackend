import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A subtle gradient background for screens
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColors = colors ??
        (isDark
            ? [
                AppTheme.backgroundDark,
                const Color(0xFF111827),
              ]
            : [
                AppTheme.backgroundLight,
                const Color(0xFFFFFFFF),
              ]);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: defaultColors,
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
}

/// A decorative circle for background depth
class DecorativeCircle extends StatelessWidget {
  final double size;
  final Color? color;
  final AlignmentGeometry alignment;
  final double opacity;

  const DecorativeCircle({
    super.key,
    required this.size,
    this.color,
    this.alignment = Alignment.center,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final circleColor = color ??
        (isDark
            ? Colors.white.withValues(alpha: opacity)
            : AppTheme.primaryColor.withValues(alpha: opacity));

    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              circleColor,
              circleColor.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
