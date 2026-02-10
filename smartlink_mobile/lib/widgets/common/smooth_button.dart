import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// A smooth animated button with multiple styles
class SmoothButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final SmoothButtonStyle style;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const SmoothButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.style = SmoothButtonStyle.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
    this.borderRadius = AppTheme.radiusMd,
  });

  @override
  State<SmoothButton> createState() => _SmoothButtonState();
}

enum SmoothButtonStyle {
  primary,
  secondary,
  outline,
  ghost,
}

class _SmoothButtonState extends State<SmoothButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppTheme.fastAnimation,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: (_) => isEnabled ? _controller.forward() : null,
      onTapUp: (_) {
        if (isEnabled) {
          _controller.reverse();
          widget.onPressed?.call();
        }
      },
      onTapCancel: () => isEnabled ? _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppTheme.normalAnimation,
          curve: AppTheme.smoothCurve,
          width: widget.isFullWidth ? double.infinity : null,
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.space2Xl,
                vertical: AppTheme.spaceMd + 2,
              ),
          decoration: _getDecoration(isDark, isEnabled),
          child: _buildContent(context),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(bool isDark, bool isEnabled) {
    final opacity = isEnabled ? 1.0 : 0.5;

    switch (widget.style) {
      case SmoothButtonStyle.primary:
        return BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: opacity),
              AppTheme.primaryDark.withValues(alpha: opacity),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );

      case SmoothButtonStyle.secondary:
        return BoxDecoration(
          color: (isDark ? AppTheme.surfaceDark : Colors.white)
              .withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
            width: 1.5,
          ),
          boxShadow: isEnabled
              ? (isDark ? AppTheme.softShadowDark : AppTheme.softShadowLight)
              : null,
        );

      case SmoothButtonStyle.outline:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: opacity),
            width: 2,
          ),
        );

      case SmoothButtonStyle.ghost:
        return BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: isEnabled ? 0.1 : 0.05),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        );
    }
  }

  Widget _buildContent(BuildContext context) {
    final textColor = _getTextColor(context);
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        );

    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 20, color: textColor),
          const SizedBox(width: AppTheme.spaceSm),
          Text(widget.text, style: textStyle),
        ],
      );
    }

    return Center(
      child: Text(widget.text, style: textStyle),
    );
  }

  Color _getTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (widget.style) {
      case SmoothButtonStyle.primary:
        return Colors.white;
      case SmoothButtonStyle.secondary:
        return isDark ? Colors.white : AppTheme.textMain;
      case SmoothButtonStyle.outline:
      case SmoothButtonStyle.ghost:
        return AppTheme.primaryColor;
    }
  }
}
