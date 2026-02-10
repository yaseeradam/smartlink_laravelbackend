import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import 'shimmer_box.dart';

class ShopCard extends StatefulWidget {
  final Map<String, dynamic> shop;
  final VoidCallback? onTap;

  const ShopCard({
    super.key,
    required this.shop,
    this.onTap,
  });

  @override
  State<ShopCard> createState() => _ShopCardState();
}

class _ShopCardState extends State<ShopCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.fastAnimation,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.smoothCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;
    final shadows = isDark ? AppTheme.mediumShadowDark : AppTheme.mediumShadowLight;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: outline, width: 1),
            boxShadow: shadows,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shop image with gradient overlay
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusLg),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.shop['image'] ?? '',
                      height: 192,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const ShimmerBox(
                        height: 192,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusLg),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 192,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                              (isDark ? const Color(0xFF1F2937) : const Color(0xFFD1D5DB)),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.store, size: 48, color: Colors.white54),
                      ),
                    ),
                  ),
                  // Subtle gradient overlay for depth
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppTheme.radiusLg),
                        ),
                      ),
                    ),
                  ),
                  // Trusted badge with soft shadow
                  if (widget.shop['trusted'] == true)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceSm + 2,
                          vertical: AppTheme.spaceXs + 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 14,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: AppTheme.spaceXs),
                            Text(
                              'Trusted',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppTheme.textMain,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Shop details with better spacing
              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.shop['name'] ?? 'Unknown Shop',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppTheme.spaceXs),
                              Text(
                                '${widget.shop['category'] ?? 'Retail'} • ${widget.shop['distance']?.toStringAsFixed(1) ?? '0.0'} km',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSm),
                        // Rating badge with soft background
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spaceSm,
                            vertical: AppTheme.spaceXs,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor.withValues(alpha: 0.15),
                                AppTheme.primaryColor.withValues(alpha: 0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: AppTheme.spaceXs),
                              Text(
                                widget.shop['rating']?.toStringAsFixed(1) ?? '0.0',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Divider(height: 1, color: outline, thickness: 1),
                    const SizedBox(height: AppTheme.spaceSm),
                    // Delivery info with icons
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spaceXs),
                          decoration: BoxDecoration(
                            color: (widget.shop['deliveryType'] == 'Pilot Delivery'
                                    ? AppTheme.primaryColor
                                    : Colors.blue)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: Icon(
                            Icons.rocket_launch_rounded,
                            size: 16,
                            color: widget.shop['deliveryType'] == 'Pilot Delivery'
                                ? AppTheme.primaryColor
                                : Colors.blue,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spaceSm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.shop['deliveryType'] ?? 'Standard Delivery',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: widget.shop['deliveryType'] == 'Pilot Delivery'
                                          ? AppTheme.primaryColor
                                          : Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.shop['deliveryTime'] ?? 'Varies',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondaryDark
                                          : AppTheme.textSecondary,
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
            ],
          ),
        ),
      ),
    );
  }
}
