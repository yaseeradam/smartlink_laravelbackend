import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class OtpVerifyArgs {
  final String phone;
  final String purposeLabel;
  final String nextRouteName;

  const OtpVerifyArgs({
    required this.phone,
    required this.purposeLabel,
    required this.nextRouteName,
  });
}

class OtpVerifyScreen extends StatefulWidget {
  final OtpVerifyArgs args;

  const OtpVerifyScreen({super.key, required this.args});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    try {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      auth.markPhoneVerified();

      Navigator.pushNamedAndRemoveUntil(context, widget.args.nextRouteName, (r) => false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Verify'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One-time code',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.args.purposeLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sent to ${widget.args.phone}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _verify(),
                        decoration: const InputDecoration(
                          labelText: '6-digit code',
                          prefixIcon: Icon(Icons.lock_clock_outlined),
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.length < 4) return 'Enter the code';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _verify,
                      child: Text(_isLoading ? 'Verifying…' : 'Verify'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'Tip: Use OTP_DRIVER=log in the backend to log codes locally.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white60 : Colors.black45,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
