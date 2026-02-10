import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';

class WalletCardCustomizeScreen extends StatefulWidget {
  const WalletCardCustomizeScreen({super.key});

  @override
  State<WalletCardCustomizeScreen> createState() =>
      _WalletCardCustomizeScreenState();
}

class _WalletCardCustomizeScreenState extends State<WalletCardCustomizeScreen> {
  bool _saving = false;
  String _theme = 'default';

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiClient.instance
          .patchJson('wallet/card', body: {'theme': _theme});
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const themes = ['default', 'midnight', 'mint', 'sunset', 'ocean'];

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Customize card')),
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
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Theme',
                prefixIcon: Icon(Icons.palette_outlined),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _theme,
                  isExpanded: true,
                  items: themes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(growable: false),
                  onChanged: _saving
                      ? null
                      : (v) => setState(() => _theme = v ?? _theme),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save'),
          ),
        ],
      ),
    );
  }
}
