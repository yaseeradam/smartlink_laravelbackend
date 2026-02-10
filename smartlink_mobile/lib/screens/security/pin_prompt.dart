import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/security_provider.dart';

class PinPrompt {
  static Future<bool> verify(BuildContext context, {required String reason}) async {
    final security = context.read<SecurityProvider>();
    if (!security.hasPin) return true;

    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter PIN',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reason,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Transaction PIN',
                      prefixIcon: Icon(Icons.pin_outlined),
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 4) return 'Enter your PIN';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      final valid = await security.verifyPin(controller.text.trim());
                      if (!context.mounted) return;
                      if (!valid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Incorrect PIN')),
                        );
                        return;
                      }
                      Navigator.pop(context, true);
                    },
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    controller.dispose();
    return ok ?? false;
  }
}

