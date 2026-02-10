import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A beautifully animated card with smooth shadows and optional gradient overlay
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double borderRadius;
  final bool enableShadow;
  final bool enableHoverEffect;
  final Duration animationDuration;

  const AnimatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.borderRadius = AppTheme.radiusLg,
    this.enableShadow = true,
    this.enableHoverEffect = true,
    this.animationDuration = AppTheme.normalAnimation,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.smoothCurve),
    );
    _elevationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.smoothCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enableHoverEffect) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enableHoverEffect) {
      _controller.reverse();
    }
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    if (widget.enableHoverEffect) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shadows = widget.enableShadow
        ? (isDark ? AppTheme.mediumShadowDark : AppTheme.mediumShadowLight)
        : <BoxShadow>[];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: widget.margin,
            decoration: BoxDecoration(
              color: widget.gradient == null
                  ? (widget.backgroundColor ??
                      (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight))
                  : null,
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: shadows.map((shadow) {
                return BoxShadow(
                  color: shadow.color,
                  blurRadius: shadow.blurRadius * (1 + _elevationAnimation.value * 0.2),
                  offset: shadow.offset,
                );
              }).toList(),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: InkWell(
                onTap: widget.onTap,
                onTapDown: _handleTapDown,
                onTapUp: _handleTapUp,
                onTapCancel: _handleTapCancel,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashFactory: InkSparkle.splashFactory,
                child: Padding(
                  padding: widget.padding ?? const EdgeInsets.all(AppTheme.spaceLg),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
