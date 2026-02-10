import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navTimer = Timer(const Duration(milliseconds: 3000), () async {
        if (!mounted) return;
        final next = await _nextRoute();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, next);
      });
    });
  }

  Future<String> _nextRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool('onboarding_completed') ?? false;
      if (!done) return AppRouter.onboarding;

      if (!mounted) return AppRouter.auth;
      await context.read<AuthProvider>().tryRestoreSession();
      if (!mounted) return AppRouter.auth;
      return context.read<AuthProvider>().isAuthenticated
          ? AppRouter.home
          : AppRouter.auth;
    } catch (_) {
      return AppRouter.onboarding;
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Gradient Mesh
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFF8FAFC),
                    Colors.white,
                    Color(0xFFF1F5F9),
                  ],
                ),
              ),
            ),
          ),

          // 2. Animated Floating Blurred Elements
          _AnimatedBlurCircle(
            controller: _floatingController,
            top: -100,
            right: -100,
            size: 400,
            color: AppTheme.primaryColor.withValues(alpha: 0.08),
            offsetMultiplier: 1.0,
          ),
          _AnimatedBlurCircle(
            controller: _floatingController,
            bottom: -50,
            left: -150,
            size: 500,
            color: const Color(0xFF6366F1).withValues(alpha: 0.06),
            offsetMultiplier: -1.2,
          ),
          _AnimatedBlurCircle(
            controller: _floatingController,
            top: 200,
            left: -100,
            size: 300,
            color: const Color(0xFF21c45d).withValues(alpha: 0.04),
            offsetMultiplier: 0.8,
          ),

          // 3. Main Content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  // Logo with Glassmorphism
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft outer glow
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          ),
                        ),
                        // Glass container
                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryColor,
                                    Color(0xFF1ba84f),
                                  ],
                                ).createShader(bounds),
                                child: const Icon(
                                  Icons.link_rounded,
                                  size: 56,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // App Branding
                  Text(
                    'SmartLink',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: AppTheme.textMain,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Trusted • Protected • Verified',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Loading Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 160,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              backgroundColor:
                                  AppTheme.primaryColor.withValues(alpha: 0.1),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'The trust-first neighborhood marketplace',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black38,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedBlurCircle extends StatelessWidget {
  final AnimationController controller;
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final double offsetMultiplier;

  const _AnimatedBlurCircle({
    required this.controller,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
    required this.offsetMultiplier,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          top: top != null
              ? top! + (controller.value * 30 * offsetMultiplier)
              : null,
          bottom: bottom != null
              ? bottom! + (controller.value * 20 * offsetMultiplier)
              : null,
          left: left != null
              ? left! + (controller.value * 25 * offsetMultiplier)
              : null,
          right: right != null
              ? right! + (controller.value * 15 * offsetMultiplier)
              : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
        );
      },
    );
  }
}
