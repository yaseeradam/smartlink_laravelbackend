import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  AppRole _roleHint = AppRole.customer;

  final _loginFormKey = GlobalKey<FormState>();

  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRoleHint();
  }

  Future<void> _loadRoleHint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('preferred_role');
      if (!mounted) return;
      setState(() => _roleHint = AppRoleX.fromApiValue(raw));
    } catch (_) {}
  }

  Future<void> _setRoleHint(AppRole role) async {
    setState(() => _roleHint = role);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preferred_role', role.apiValue);
    } catch (_) {}
  }

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_loginFormKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final identifier = _loginIdentifierController.text.trim();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('preferred_role', _roleHint.apiValue);
      } catch (_) {}

      if (!mounted) return;
      await context.read<AuthProvider>().loginDemo(
            role: _roleHint,
            identifier: identifier,
          );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme.copyWith(
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: AppTheme.lightTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textMain,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textMain,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              // Background Gradient Mesh
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
              // Soft Blur Circles
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight - 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          _Header(roleSubtitle: _roleHint.subtitle),
                          const SizedBox(height: 24),
                          _RolePicker(
                            selectedRole: _roleHint,
                            onChanged: _setRoleHint,
                          ),
                          const SizedBox(height: 16),
                          _RoleDetails(role: _roleHint),
                          const SizedBox(height: 24),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(32),
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.02),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 16, 20, 24),
                                    child: _LoginForm(
                                      key: const ValueKey('login_form'),
                                      formKey: _loginFormKey,
                                      identifierController:
                                          _loginIdentifierController,
                                      passwordController:
                                          _loginPasswordController,
                                      isLoading: _isLoading,
                                      actionLabel:
                                          'Continue as ${_roleHint.label}',
                                      onSubmit: _login,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'New here?',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.pushNamed(
                                          context,
                                          AppRouter.register,
                                        ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Create account'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Column(
                            children: [
                              Text(
                                'Trusted by thousands of users worldwide',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _SecurityBadge(
                                      icon: Icons.verified_user_outlined,
                                      label: 'Secure'),
                                  SizedBox(width: 24),
                                  _SecurityBadge(
                                      icon: Icons.speed_outlined,
                                      label: 'Fast'),
                                  SizedBox(width: 24),
                                  _SecurityBadge(
                                      icon: Icons.support_agent_outlined,
                                      label: '24/7'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Opacity(
                            opacity: 0.6,
                            child: Text(
                              "By continuing, you agree to SmartLink's\nTerms of Service and Privacy Policy.",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    height: 1.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  AppRole _selectedRole = AppRole.customer;

  final _registerFormKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('preferred_role');
      if (!mounted) return;
      setState(() => _selectedRole = AppRoleX.fromApiValue(raw));
    } catch (_) {}
  }

  Future<void> _setRole(AppRole role) async {
    setState(() => _selectedRole = role);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('preferred_role', role.apiValue);
    } catch (_) {}
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_registerFormKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AuthProvider>().registerDemo(
            role: _selectedRole,
            fullName: _fullNameController.text.trim().isEmpty
                ? null
                : _fullNameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          );

      if (!mounted) return;
      context.read<AuthProvider>().markPhoneVerified();
      Navigator.pushReplacementNamed(context, AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme.copyWith(
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: AppTheme.lightTheme.inputDecorationTheme.copyWith(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textMain,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textMain,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
              Positioned(
                top: -100,
                right: -100,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF6366F1).withValues(alpha: 0.05),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight - 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          _Header(roleSubtitle: _selectedRole.subtitle),
                          const SizedBox(height: 24),
                          _RolePicker(
                            selectedRole: _selectedRole,
                            onChanged: _setRole,
                          ),
                          const SizedBox(height: 18),
                          _RoleDetails(role: _selectedRole),
                          const SizedBox(height: 24),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOutCubic,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(32),
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                  BoxShadow(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.02),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 20, 24),
                                child: _RegisterForm(
                                  key: const ValueKey('register_form'),
                                  formKey: _registerFormKey,
                                  fullNameController: _fullNameController,
                                  phoneController: _phoneController,
                                  emailController: _emailController,
                                  passwordController:
                                      _registerPasswordController,
                                  isLoading: _isLoading,
                                  onSubmit: _register,
                                  roleLabel: _selectedRole.label,
                                  actionLabel:
                                      'Continue as ${_selectedRole.label}',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.black54),
                              ),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.pushReplacementNamed(
                                          context,
                                          AppRouter.auth,
                                        ),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  visualDensity: VisualDensity.compact,
                                ),
                                child: const Text('Sign in'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Column(
                            children: [
                              Text(
                                'Trusted by thousands of users worldwide',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _SecurityBadge(
                                      icon: Icons.verified_user_outlined,
                                      label: 'Secure'),
                                  SizedBox(width: 24),
                                  _SecurityBadge(
                                      icon: Icons.speed_outlined,
                                      label: 'Fast'),
                                  SizedBox(width: 24),
                                  _SecurityBadge(
                                      icon: Icons.support_agent_outlined,
                                      label: '24/7'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          Opacity(
                            opacity: 0.6,
                            child: Text(
                              "By continuing, you agree to SmartLink's\nTerms of Service and Privacy Policy.",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    height: 1.5,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String roleSubtitle;
  const _Header({required this.roleSubtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.link, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to SmartLink',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'SmartLink',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                fontSize: 32,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          roleSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RolePicker extends StatelessWidget {
  final AppRole selectedRole;
  final ValueChanged<AppRole> onChanged;

  const _RolePicker({required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'I am a...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
          ),
        ),
        Row(
          children: [
            _RoleCard(
              role: AppRole.customer,
              icon: Icons.person_outline_rounded,
              selected: selectedRole == AppRole.customer,
              onTap: () => onChanged(AppRole.customer),
            ),
            const SizedBox(width: 12),
            _RoleCard(
              role: AppRole.merchant,
              icon: Icons.storefront_rounded,
              selected: selectedRole == AppRole.merchant,
              onTap: () => onChanged(AppRole.merchant),
            ),
            const SizedBox(width: 12),
            _RoleCard(
              role: AppRole.rider,
              icon: Icons.directions_bike_rounded,
              selected: selectedRole == AppRole.rider,
              onTap: () => onChanged(AppRole.rider),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final AppRole role;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppTheme.primaryColor : const Color(0xFFE2E8F0),
              width: 1.5,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : AppTheme.textMain,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                role.label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textMain,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleDetails extends StatelessWidget {
  final AppRole role;

  const _RoleDetails({required this.role});

  @override
  Widget build(BuildContext context) {
    final title = switch (role) {
      AppRole.customer => 'Buyer demo access',
      AppRole.merchant => 'Seller demo access',
      AppRole.rider => 'Rider demo access',
    };
    final items = switch (role) {
      AppRole.customer => const [
          'Browse shops, products, and services',
          'Cart, checkout, and order tracking',
          'Wallet, returns, and disputes',
        ],
      AppRole.merchant => const [
          'Manage shop, products, and categories',
          'Seller orders, earnings, and escrow holds',
          'Service requests and coverage areas',
        ],
      AppRole.rider => const [
          'Dispatch offers and rider orders',
          'Availability, stats, and profile',
          'Proof of delivery and messages',
        ],
    };
    final routeNote = switch (role) {
      AppRole.customer => 'Routes to Customer home screen.',
      AppRole.merchant => 'Routes to Merchant home screen.',
      AppRole.rider => 'Routes to Rider home screen.',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textMain,
                ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      size: 18, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            routeNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'No real auth yet. Select a role to preview screens.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SecurityBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black38),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black45,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String actionLabel;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.formKey,
    required this.identifierController,
    required this.passwordController,
    required this.isLoading,
    required this.actionLabel,
    required this.onSubmit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sign in',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: identifierController,
            autofillHints: const [
              AutofillHints.username,
              AutofillHints.email,
              AutofillHints.telephoneNumber
            ],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Phone or email (optional)',
              prefixIcon: Icon(Icons.alternate_email_rounded),
              hintText: 'e.g. +2348012345678',
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              labelText: 'Password (optional)',
              prefixIcon: Icon(Icons.lock_person_outlined),
            ),
            validator: (value) {
              final text = value ?? '';
              if (text.isNotEmpty && text.length < 4) {
                return 'Password is too short';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isLoading ? null : () {},
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Forgot password?'),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              elevation: 8,
              shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
            child: Text(isLoading ? 'Signing in...' : actionLabel),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('or continue with',
                    style: TextStyle(
                        color: Colors.black26,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SocialButton(
                  iconPath: 'assets/google_logo.png', // Note: placeholder paths
                  label: 'Google',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SocialButton(
                  iconPath: 'assets/apple_logo.png',
                  label: 'Apple',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final String roleLabel;
  final String actionLabel;

  const _RegisterForm({
    required this.formKey,
    required this.fullNameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSubmit,
    required this.roleLabel,
    required this.actionLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Create account',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  roleLabel,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textMain,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: fullNameController,
            autofillHints: const [AutofillHints.name],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Full name (optional)',
              prefixIcon: Icon(Icons.person_pin_rounded),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isNotEmpty && text.length < 2) {
                return 'Name is too short';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: phoneController,
            autofillHints: const [AutofillHints.telephoneNumber],
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Phone number (optional)',
              prefixIcon: Icon(Icons.phone_iphone_rounded),
              hintText: 'e.g. +2348012345678',
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isNotEmpty && text.length < 8) {
                return 'Enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            autofillHints: const [AutofillHints.email],
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email (optional)',
              prefixIcon: Icon(Icons.mail_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: const InputDecoration(
              labelText: 'Password (optional)',
              prefixIcon: Icon(Icons.lock_person_outlined),
            ),
            validator: (value) {
              final text = value ?? '';
              if (text.isNotEmpty && text.length < 4) {
                return 'Password is too short';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              elevation: 8,
              shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
            child: Text(
              isLoading ? 'Creating account...' : actionLabel,
            ),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('or register with',
                    style: TextStyle(
                        color: Colors.black26,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _SocialButton(
                  iconPath: 'assets/google_logo.png',
                  label: 'Google',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SocialButton(
                  iconPath: 'assets/apple_logo.png',
                  label: 'Apple',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            label == 'Google'
                ? Icons.g_mobiledata_rounded
                : Icons.apple_rounded,
            color: Colors.black87,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
