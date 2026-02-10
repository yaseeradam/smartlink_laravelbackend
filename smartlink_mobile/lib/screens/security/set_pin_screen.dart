import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/security_provider.dart';

class SetPinScreen extends StatefulWidget {
  const SetPinScreen({super.key});

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPinController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _oldPinController.dispose();
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      await context.read<SecurityProvider>().setPin(
            newPin: _pinController.text.trim(),
            oldPin: _oldPinController.text.trim().isEmpty ? null : _oldPinController.text.trim(),
          );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN updated.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPin = context.watch<SecurityProvider>().hasPin;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text(hasPin ? 'Change PIN' : 'Set PIN')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (hasPin) ...[
                    TextFormField(
                      controller: _oldPinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Old PIN',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) {
                        final text = v?.trim() ?? '';
                        if (text.length < 4) return 'Old PIN required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New PIN (4–10 digits)',
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                    validator: (v) {
                      final text = v?.trim() ?? '';
                      if (text.length < 4) return 'PIN too short';
                      if (text.length > 10) return 'PIN too long';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm PIN',
                      prefixIcon: Icon(Icons.check_circle_outline),
                    ),
                    validator: (v) {
                      final text = v?.trim() ?? '';
                      if (text != _pinController.text.trim()) return 'PINs do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Saving…' : 'Save'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

