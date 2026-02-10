import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';
import 'seller_metrics_screen.dart';

class MyShopScreen extends StatefulWidget {
  const MyShopScreen({super.key});

  @override
  State<MyShopScreen> createState() => _MyShopScreenState();
}

class _MyShopScreenState extends State<MyShopScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _shops = const [];
  List<Map<String, dynamic>> _zones = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadZones();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.getJson('seller/shops');
      final raw = (res['data'] as List?) ?? const [];
      final items = raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      if (!mounted) return;
      setState(() => _shops = items);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadZones() async {
    try {
      final res = await ApiClient.instance.getJson('zones');
      final raw = (res['data'] as List?) ?? const [];
      final items = raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      if (!mounted) return;
      setState(() => _zones = items);
    } catch (_) {}
  }

  Future<void> _openEditor({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final nameController = TextEditingController(text: (existing?['shop_name'] as String?) ?? '');
    final descriptionController = TextEditingController(text: (existing?['description'] as String?) ?? '');
    final addressController = TextEditingController(text: (existing?['address_text'] as String?) ?? '');
    final coverController = TextEditingController(text: (existing?['cover_image_url'] as String?) ?? '');
    int? zoneId = existing?['zone_id'] as int?;
    zoneId ??= _zones.isNotEmpty ? _zones.first['id'] as int? : null;
    String shippingType = (existing?['shipping_type'] as String?) ?? 'local_rider';
    bool isOpen = (existing?['is_open'] as bool?) ?? true;
    bool deliverOutside = (existing?['is_deliverable_outside_state'] as bool?) ?? false;
    String shopType = (existing?['shop_type'] as String?) ?? 'retail';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit shop' : 'Create shop'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Shop name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: coverController,
                      decoration: const InputDecoration(labelText: 'Cover image URL'),
                    ),
                    const SizedBox(height: 10),
                    if (!isEdit && _zones.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: zoneId,
                        items: _zones
                            .map(
                              (z) => DropdownMenuItem<int>(
                                value: z['id'] as int?,
                                child: Text('${z['state'] ?? ''} ${z['city'] ?? ''}'),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) => setDialogState(() => zoneId = value),
                        decoration: const InputDecoration(labelText: 'Zone'),
                      ),
                    if (!isEdit) const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: shopType,
                      items: const [
                        DropdownMenuItem(value: 'retail', child: Text('Retail')),
                        DropdownMenuItem(value: 'food', child: Text('Food')),
                        DropdownMenuItem(value: 'repair', child: Text('Repair')),
                        DropdownMenuItem(value: 'tailor', child: Text('Tailor')),
                        DropdownMenuItem(value: 'laundry', child: Text('Laundry')),
                        DropdownMenuItem(value: 'print', child: Text('Print')),
                      ],
                      onChanged: (value) => setDialogState(() => shopType = value ?? shopType),
                      decoration: const InputDecoration(labelText: 'Shop type'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: shippingType,
                      items: const [
                        DropdownMenuItem(value: 'local_rider', child: Text('Local rider')),
                        DropdownMenuItem(value: 'state_shipping', child: Text('State shipping')),
                        DropdownMenuItem(value: 'nation_shipping', child: Text('Nation shipping')),
                      ],
                      onChanged: (value) => setDialogState(() => shippingType = value ?? shippingType),
                      decoration: const InputDecoration(labelText: 'Shipping type'),
                    ),
                    const SizedBox(height: 10),
                    SwitchListTile.adaptive(
                      value: isOpen,
                      onChanged: (value) => setDialogState(() => isOpen = value),
                      title: const Text('Shop is open'),
                    ),
                    SwitchListTile.adaptive(
                      value: deliverOutside,
                      onChanged: (value) => setDialogState(() => deliverOutside = value),
                      title: const Text('Deliver outside state'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final address = addressController.text.trim();
                    if (name.isEmpty || address.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Shop name and address are required.')),
                      );
                      return;
                    }
                    if (!isEdit && zoneId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select a zone for this shop.')),
                      );
                      return;
                    }
                    try {
                      if (isEdit) {
                        await ApiClient.instance.patchJson(
                          'seller/shops/${existing!['id']}',
                          body: {
                            'shop_name': name,
                            'description': descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            'address_text': address,
                            'cover_image_url': coverController.text.trim().isEmpty
                                ? null
                                : coverController.text.trim(),
                            'is_open': isOpen,
                            'shipping_type': shippingType,
                            'is_deliverable_outside_state': deliverOutside,
                          },
                        );
                      } else {
                        await ApiClient.instance.postJson(
                          'seller/shop',
                          body: {
                            'shop_name': name,
                            'description': descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            'address_text': address,
                            'zone_id': zoneId,
                            'shop_type': shopType,
                          },
                        );
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

    nameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    coverController.dispose();

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
      return const _NotAuthorizedScreen(title: 'My Shop');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          IconButton(
            onPressed: _openEditor,
            icon: const Icon(Icons.add),
            tooltip: 'Create shop',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null && _shops.isEmpty) _EmptyCard(isDark: isDark, message: 'No shops yet.'),
            if (!_loading && _error == null)
              ..._shops.map((shop) {
                final id = shop['id'];
                final name = (shop['shop_name'] as String?) ?? 'Shop';
                final address = (shop['address_text'] as String?) ?? '';
                final status = (shop['status'] as String?) ?? '';
                final isOpen = (shop['is_open'] as bool?) ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: outline),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                          blurRadius: 22,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.storefront_outlined, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (address.trim().isNotEmpty) address.trim(),
                                  if (status.trim().isNotEmpty) status.trim(),
                                  if (isOpen) 'Open' else 'Closed',
                                ].join(' | '),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _openEditor(existing: shop);
                            } else if (value == 'metrics') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SellerMetricsScreen()),
                              );
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'metrics', child: Text('Metrics')),
                          ],
                          icon: Icon(Icons.more_horiz_rounded, color: isDark ? Colors.white60 : Colors.black45),
                        ),
                      ],
                    ),
                  ),
                );
              }),
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
            'Could not load shops',
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
          Icon(Icons.storefront_outlined, color: isDark ? Colors.white54 : Colors.black45),
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
