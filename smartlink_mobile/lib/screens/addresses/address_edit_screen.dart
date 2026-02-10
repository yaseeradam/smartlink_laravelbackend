import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/address_provider.dart';
import '../locations/state_picker_screen.dart';
import '../locations/city_picker_screen.dart';

class AddressEditScreen extends StatefulWidget {
  final SmartlinkAddress? address;
  const AddressEditScreen({super.key, this.address});

  @override
  State<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _addressTextController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address?.label ?? '');
    _addressTextController = TextEditingController(text: widget.address?.addressText ?? '');
    _cityController = TextEditingController(text: widget.address?.city ?? '');
    _stateController = TextEditingController(text: widget.address?.state ?? '');
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressTextController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    final id = widget.address?.id ?? 'addr_$now';

    final address = SmartlinkAddress(
      id: id,
      label: _labelController.text.trim().isEmpty ? null : _labelController.text.trim(),
      addressText: _addressTextController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
      countryCode: widget.address?.countryCode ?? 'NG',
      isDefault: _isDefault,
    );

    await context.read<AddressProvider>().upsert(address);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.address != null;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text(isEdit ? 'Edit address' : 'Add address')),
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
                  TextFormField(
                    controller: _labelController,
                    decoration: const InputDecoration(
                      labelText: 'Label (optional)',
                      prefixIcon: Icon(Icons.bookmark_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressTextController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Full address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                    validator: (value) {
                      final v = value?.trim() ?? '';
                      if (v.length < 8) return 'Enter a valid address';
                      if (v.length > 255) return 'Address is too long';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cityController,
                          readOnly: true,
                          onTap: () async {
                            final state = _stateController.text.trim();
                            if (state.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Select a state first.')),
                              );
                              return;
                            }

                            final selected = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CityPickerScreen(
                                  state: state,
                                  selected: _cityController.text.trim().isEmpty
                                      ? null
                                      : _cityController.text.trim(),
                                ),
                              ),
                            );
                            if (selected == null || !mounted) return;
                            setState(() => _cityController.text = selected);
                          },
                          decoration: const InputDecoration(
                            labelText: 'City (optional)',
                            suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _stateController,
                          readOnly: true,
                          onTap: () async {
                            final selected = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StatePickerScreen(
                                  selected: _stateController.text.trim().isEmpty
                                      ? null
                                      : _stateController.text.trim(),
                                ),
                              ),
                            );
                            if (selected == null || !mounted) return;
                            setState(() {
                              _stateController.text = selected;
                              _cityController.clear();
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'State (optional)',
                            suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v),
                    title: const Text('Set as default'),
                    activeThumbColor: AppTheme.primaryColor,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _save,
                    child: Text(isEdit ? 'Save changes' : 'Save address'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Note: For on-site services, phone and full address can be hidden until payment is held (backend setting).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : Colors.black45,
                ),
          ),
        ],
      ),
    );
  }
}
