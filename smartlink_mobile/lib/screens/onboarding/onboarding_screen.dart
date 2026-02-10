import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      title: 'Shop with confidence',
      description: 'A trust-first marketplace with verified sellers and protected payments.',
      icon: Icons.verified_user_outlined,
      image: 'https://images.pexels.com/photos/6150507/pexels-photo-6150507.jpeg',
      bullets: [
        'Verified sellers and trust signals',
        'Escrow holds until you confirm delivery',
        'Fast support when something goes wrong',
      ],
    ),
    OnboardingData(
      title: 'Protected payments',
      description: 'Your money is held safely. Sellers get paid only when you confirm.',
      icon: Icons.lock_outline,
      image: 'https://images.pexels.com/photos/6265004/pexels-photo-6265004.jpeg',
      bullets: [
        'Escrow holds for orders and services',
        'Refunds and dispute support',
        'Transaction history in your wallet',
      ],
    ),
    OnboardingData(
      title: 'Delivered by trusted pilots',
      description: 'Hyper-local delivery powered by nearby riders and pilots.',
      icon: Icons.two_wheeler_outlined,
      image: 'https://images.pexels.com/photos/4391470/pexels-photo-4391470.jpeg',
      bullets: [
        'Local-first delivery experience',
        'Real-time order tracking',
        'Proofs & confirmation flows',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
    } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRouter.auth);
  }

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _OnboardingPage(
                key: ValueKey('page_$index'),
                data: _pages[index],
                index: index,
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 18,
            right: 18,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: outline),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.link, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'SmartLink',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.35 : 0.85),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: outline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final selected = _currentPage == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: selected ? 26 : 8,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primaryColor
                                  : AppTheme.primaryColor.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Visibility(
                              visible: _currentPage < _pages.length - 1,
                              maintainSize: true,
                              maintainAnimation: true,
                              maintainState: true,
                              child: TextButton(
                                onPressed: _isSaving ? null : _completeOnboarding,
                                child: const Text('Skip'),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _goNext,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                elevation: 0,
                              ),
                              child: Text(_currentPage == _pages.length - 1 ? 'Get started' : 'Next'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final int index;

  const _OnboardingPage({required this.data, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 62, 18, 130),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        data.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
                            ),
                            child: Center(
                              child: Icon(
                                data.icon,
                                size: 92,
                                color: AppTheme.primaryColor.withValues(alpha: 0.55),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.transparent,
                              (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight)
                                  .withValues(alpha: 0.92),
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.black : Colors.white).withValues(alpha: isDark ? 0.50 : 0.88),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(color: outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(data.icon, color: AppTheme.primaryColor),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              data.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data.description,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    height: 1.35,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            ...data.bullets.map(
                              (b) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.check, size: 12, color: AppTheme.primaryColor),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        b,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: isDark ? Colors.white70 : Colors.black54,
                                              height: 1.35,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final String image;
  final List<String> bullets;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.image,
    required this.bullets,
  });
}
