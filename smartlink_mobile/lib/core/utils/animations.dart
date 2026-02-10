import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animation utilities for smooth transitions throughout the app
class Animations {
  /// Fade in animation with optional slide from bottom
  static Widget fadeInSlide({
    required Widget child,
    Duration delay = Duration.zero,
    Duration duration = AppTheme.normalAnimation,
    Curve curve = AppTheme.smoothCurve,
    Offset slideOffset = const Offset(0, 0.05),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(
              slideOffset.dx * (1 - value) * 100,
              slideOffset.dy * (1 - value) * 100,
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Scale animation for interactive elements
  static Widget scaleIn({
    required Widget child,
    Duration duration = AppTheme.normalAnimation,
    Curve curve = AppTheme.bounceCurve,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Staggered animation for list items
  static Widget staggeredListItem({
    required Widget child,
    required int index,
    Duration baseDelay = const Duration(milliseconds: 50),
    Duration duration = AppTheme.normalAnimation,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: AppTheme.smoothCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Shimmer animation for loading states
  static AnimationController createShimmerController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  /// Create a smooth bounce animation controller
  static AnimationController createBounceController(TickerProvider vsync) {
    return AnimationController(
      vsync: vsync,
      duration: AppTheme.slowAnimation,
    );
  }

  /// Animate a value with smooth curve
  static Animation<double> createSmoothAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = AppTheme.smoothCurve,
  }) {
    return CurvedAnimation(
      parent: controller,
      curve: curve,
    );
  }
}

/// Extension for adding smooth tap feedback to widgets
extension SmoothTappable on Widget {
  Widget withSmoothTap({
    required VoidCallback? onTap,
    double scaleValue = 0.95,
    Duration duration = AppTheme.fastAnimation,
  }) {
    return _SmoothTappableWidget(
      onTap: onTap,
      scaleValue: scaleValue,
      duration: duration,
      child: this,
    );
  }
}

class _SmoothTappableWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleValue;
  final Duration duration;

  const _SmoothTappableWidget({
    required this.child,
    required this.onTap,
    required this.scaleValue,
    required this.duration,
  });

  @override
  State<_SmoothTappableWidget> createState() => _SmoothTappableWidgetState();
}

class _SmoothTappableWidgetState extends State<_SmoothTappableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleValue).animate(
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
