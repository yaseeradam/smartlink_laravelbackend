import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class MerchantServicesScreen extends StatefulWidget {
  const MerchantServicesScreen({super.key});

  @override
  State<MerchantServicesScreen> createState() => _MerchantServicesScreenState();
}

class _MerchantServicesScreenState extends State<MerchantServicesScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  List<Map<String, dynamic>> _categories = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadCategories();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.getJson('merchant/services');
      final raw = (res['data'] as List?) ?? const [];
      final items = raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      if (!mounted) return;
      setState(() => _items = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCategories() async {
    try {
      final res = await ApiClient.instance.getJson('services/categories');
      final raw = (res['data'] as List?) ?? const [];
      final items = raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      if (!mounted) return;
      setState(() => _categories = items);
    } catch (_) {}
  }

  Future<void> _toggleService(Object id) async {
    try {
      await ApiClient.instance.postJson('merchant/services/$id/toggle-active');
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _openEditor({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    int? categoryId = existing?['category_id'] as int?;
    categoryId ??= _categories.isNotEmpty ? _categories.first['id'] as int? : null;
    final titleController = TextEditingController(text: (existing?['title'] as String?) ?? '');
    final descriptionController = TextEditingController(text: (existing?['description'] as String?) ?? '');
    final fixedPriceController = TextEditingController(text: (existing?['fixed_price_amount'] as String?) ?? '');
    final visitFeeController = TextEditingController(text: (existing?['min_visit_fee'] as String?) ?? '');
    final durationController = TextEditingController(text: (existing?['duration_estimate_minutes'] ?? '').toString());
    String pricingType = (existing?['pricing_type'] as String?) ?? 'quote';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit service' : 'Create service'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_categories.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: categoryId,
                        items: _categories
                            .map(
                              (c) => DropdownMenuItem<int>(
                                value: c['id'] as int?,
                                child: Text((c['name'] as String?) ?? 'Category'),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) => setDialogState(() => categoryId = value),
                        decoration: const InputDecoration(labelText: 'Category'),
                      ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: pricingType,
                      items: const [
                        DropdownMenuItem(value: 'quote', child: Text('Quote')),
                        DropdownMenuItem(value: 'fixed', child: Text('Fixed price')),
                      ],
                      onChanged: (value) => setDialogState(() => pricingType = value ?? pricingType),
                      decoration: const InputDecoration(labelText: 'Pricing type'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: fixedPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Fixed price amount'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: visitFeeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Min visit fee'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();
                    if (title.isEmpty || description.isEmpty || categoryId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Title, description, and category are required.')),
                      );
                      return;
                    }
                    final fixedPrice = double.tryParse(fixedPriceController.text.trim());
                    final visitFee = double.tryParse(visitFeeController.text.trim());
                    final duration = int.tryParse(durationController.text.trim());
                    try {
                      final payload = {
                        'category_id': categoryId,
                        'title': title,
                        'description': description,
                        'pricing_type': pricingType,
                        'fixed_price_amount': fixedPriceController.text.trim().isEmpty ? null : fixedPrice,
                        'min_visit_fee': visitFeeController.text.trim().isEmpty ? null : visitFee,
                        'duration_estimate_minutes': durationController.text.trim().isEmpty ? null : duration,
                      };
                      if (isEdit) {
                        await ApiClient.instance.dio.put(
                          'merchant/services/${existing!['id']}',
                          data: payload,
                        );
                      } else {
                        await ApiClient.instance.postJson('merchant/services', body: payload);
                      }
                      if (!mounted) return;
                      Navigator.pop(context, true);
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  child: Text(isEdit ? 'Save' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    fixedPriceController.dispose();
    visitFeeController.dispose();
    durationController.dispose();

    if (result == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    if (role != AppRole.merchant) {
      return const _NotAuthorizedScreen(title: 'Merchant services');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('My services')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null && _items.isEmpty) _EmptyCard(isDark: isDark, message: 'No services yet.'),
            if (!_loading && _error == null)
              ..._items.map((s) {
                final id = s['id'];
                final title = (s['title'] as String?) ?? 'Service';
                final category = (s['category'] as Map?)?.cast<String, dynamic>();
                final categoryName = (category?['name'] as String?) ?? '';
                final pricingType = (s['pricing_type'] as String?) ?? '';
                final isActive = (s['is_active'] as bool?) ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: outline),
                    ),
                    child: ListTile(
                      title: Text(
                        title,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        [
                          if (categoryName.trim().isNotEmpty) categoryName.trim(),
                          if (pricingType.trim().isNotEmpty) pricingType.trim(),
                        ].join(' | '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
                      ),
                      trailing: Switch.adaptive(
                        value: isActive,
                        onChanged: id == null ? null : (_) => _toggleService(id),
                        activeThumbColor: AppTheme.primaryColor,
                      ),
                      onTap: () => _openEditor(existing: s),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: _openEditor,
              icon: const Icon(Icons.add),
              label: const Text('Create service'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Could not load services',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final bool isDark;
  final String message;
  const _EmptyCard({required this.isDark, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.home_repair_service_outlined, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotAuthorizedScreen extends StatelessWidget {
  final String title;
  const _NotAuthorizedScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Not authorized for this section.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
