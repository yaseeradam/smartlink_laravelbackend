import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double diameter;

  const ShimmerCircle({super.key, required this.diameter});

  @override
  Widget build(BuildContext context) {
    return ShimmerBox(
      width: diameter,
      height: diameter,
      borderRadius: BorderRadius.circular(999),
    );
  }
}

/// Shimmer loading skeleton for cards
class ShimmerCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const ShimmerCard({
    super.key,
    this.width,
    this.height = 200,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
        ),
        boxShadow: isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight,
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
        highlightColor: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
        period: const Duration(milliseconds: 1500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusLg),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Container(
                    width: 150,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
