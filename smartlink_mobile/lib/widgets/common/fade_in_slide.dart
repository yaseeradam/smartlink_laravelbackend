import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Fade in animation with slide from bottom
class FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;
  final Curve curve;

  const FadeInSlide({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppTheme.normalAnimation,
    this.offset = const Offset(0, 30),
    this.curve = AppTheme.smoothCurve,
  });

  @override
  State<FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<FadeInSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _slideAnimation = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    // Start animation after delay
    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Staggered list with fade in slide animation
class StaggeredList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Duration baseDelay;
  final Duration staggerDelay;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;

  const StaggeredList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.baseDelay = const Duration(milliseconds: 100),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.physics,
    this.padding,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      physics: physics,
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemBuilder: (context, index) {
        return FadeInSlide(
          delay: baseDelay + (staggerDelay * index),
          child: itemBuilder(context, index),
        );
      },
    );
  }
}
