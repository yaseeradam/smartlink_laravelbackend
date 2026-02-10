import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/kyc_provider.dart';
import '../../providers/zone_provider.dart';
import '../zones/zone_picker_screen.dart';

class KycSubmitScreen extends StatefulWidget {
  const KycSubmitScreen({super.key});

  @override
  State<KycSubmitScreen> createState() => _KycSubmitScreenState();
}

class _KycSubmitScreenState extends State<KycSubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  SmartlinkKycType _type = SmartlinkKycType.buyerBasic;

  final _rcNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();

  String _vehicleType = 'bike';
  final _plateNumberController = TextEditingController();

  bool _isSubmitting = false;
  final List<SmartlinkKycDocument> _documents = [];

  @override
  void dispose() {
    _rcNumberController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDoc() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final file = await picker.pickImage(source: source, imageQuality: 82);
    if (file == null) return;

    final docType = await _pickDocType();
    if (docType == null) return;

    setState(() {
      _documents.add(SmartlinkKycDocument(docType: docType, localPath: file.path));
    });
  }

  Future<String?> _pickDocType() async {
    const types = [
      'id_front',
      'id_back',
      'selfie',
      'proof_of_address',
      'vehicle_doc',
      'business_doc',
      'document',
    ];

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Document type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...types.map(
                (t) => ListTile(
                  title: Text(t.replaceAll('_', ' ')),
                  onTap: () => Navigator.pop(context, t),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final zoneProvider = context.read<ZoneProvider>();
    if ((_type == SmartlinkKycType.seller || _type == SmartlinkKycType.rider) &&
        zoneProvider.operationalZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an operational zone for Seller/Rider KYC.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final meta = <String, dynamic>{};

      if (_type == SmartlinkKycType.seller) {
        meta['rc_number'] = _rcNumberController.text.trim();
        meta['bank_name'] = _bankNameController.text.trim();
        meta['account_number'] = _accountNumberController.text.trim();
        meta['account_name'] = _accountNameController.text.trim();
      }

      if (_type == SmartlinkKycType.rider) {
        meta['vehicle_type'] = _vehicleType;
        final plate = _plateNumberController.text.trim();
        if (plate.isNotEmpty) meta['plate_number'] = plate;
      }

      await context.read<KycProvider>().submit(
            type: _type,
            meta: meta,
            documents: _documents,
          );

      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opZoneLabel = context.watch<ZoneProvider>().operationalZoneLabel;
    final needsOperational = _type == SmartlinkKycType.seller || _type == SmartlinkKycType.rider;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Submit KYC')),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KYC type',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  _TypePicker(
                    value: _type,
                    onChanged: (t) => setState(() => _type = t),
                  ),
                  const SizedBox(height: 14),
                  if (needsOperational)
                    InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.zones,
                        arguments: const ZonePickerArgs(mode: ZonePickerMode.operational),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.place_outlined, color: AppTheme.primaryColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Operational zone',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    opZoneLabel,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isDark ? Colors.white70 : Colors.black87,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                  if (_type == SmartlinkKycType.seller) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _rcNumberController,
                      decoration: const InputDecoration(
                        labelText: 'RC number',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'RC number is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'Bank name',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Bank name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Account number',
                        prefixIcon: Icon(Icons.numbers_outlined),
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Account number is required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _accountNameController,
                      decoration: const InputDecoration(
                        labelText: 'Account name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => (v?.trim().isEmpty ?? true) ? 'Account name is required' : null,
                    ),
                  ],
                  if (_type == SmartlinkKycType.rider) ...[
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _vehicleType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle type',
                        prefixIcon: Icon(Icons.two_wheeler_outlined),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'bike', child: Text('Bike')),
                        DropdownMenuItem(value: 'car', child: Text('Car')),
                        DropdownMenuItem(value: 'tricycle', child: Text('Tricycle')),
                      ],
                      onChanged: (v) => setState(() => _vehicleType = v ?? 'bike'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _plateNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Plate number (optional)',
                        prefixIcon: Icon(Icons.confirmation_number_outlined),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Documents',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      TextButton.icon(
                        onPressed: _pickDoc,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  if (_documents.isEmpty)
                    Text(
                      'Optional (max 10). You can add ID, selfie, proof of address, etc.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                    )
                  else
                    ..._documents.asMap().entries.map((e) {
                      final i = e.key;
                      final d = e.value;
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_outlined),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.docType.replaceAll('_', ' '),
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    d.localPath,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isDark ? Colors.white70 : Colors.black54,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => setState(() => _documents.removeAt(i)),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: Text(_isSubmitting ? 'Submitting…' : 'Submit'),
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

class _TypePicker extends StatelessWidget {
  final SmartlinkKycType value;
  final ValueChanged<SmartlinkKycType> onChanged;

  const _TypePicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget tile(SmartlinkKycType type, String title, String subtitle, IconData icon) {
      final selected = type == value;
      return InkWell(
        onTap: () => onChanged(type),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10)
                : (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? AppTheme.primaryColor.withValues(alpha: 0.35)
                  : (isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                    ),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle, color: AppTheme.primaryColor),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        tile(
          SmartlinkKycType.buyerBasic,
          'Buyer basic',
          'Quick verification to strengthen trust.',
          Icons.person_outline,
        ),
        const SizedBox(height: 10),
        tile(
          SmartlinkKycType.seller,
          'Seller',
          'Business + payout details (requires operational zone).',
          Icons.storefront_outlined,
        ),
        const SizedBox(height: 10),
        tile(
          SmartlinkKycType.rider,
          'Rider',
          'Vehicle details + operational zone for dispatch.',
          Icons.two_wheeler_outlined,
        ),
      ],
    );
  }
}
