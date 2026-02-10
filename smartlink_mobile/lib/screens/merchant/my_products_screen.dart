import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  List<Map<String, dynamic>> _shops = const [];

  @override
  void initState() {
    super.initState();
    _load();
    _loadShops();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.getJson('seller/products');
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

  Future<void> _loadShops() async {
    try {
      final res = await ApiClient.instance.getJson('seller/shops');
      final raw = (res['data'] as List?) ?? const [];
      final items = raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList(growable: false);
      if (!mounted) return;
      setState(() => _shops = items);
    } catch (_) {}
  }

  Future<void> _openEditor({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final nameController = TextEditingController(text: (existing?['name'] as String?) ?? '');
    final descriptionController = TextEditingController(text: (existing?['description'] as String?) ?? '');
    final priceController = TextEditingController(text: (existing?['price'] as String?) ?? '');
    final stockController = TextEditingController(text: (existing?['stock_qty'] ?? 0).toString());
    String status = (existing?['status'] as String?) ?? 'active';
    int? shopId = existing?['shop_id'] as int?;
    shopId ??= _shops.isNotEmpty ? _shops.first['id'] as int? : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit product' : 'Create product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isEdit && _shops.isNotEmpty)
                      DropdownButtonFormField<int>(
                        value: shopId,
                        items: _shops
                            .map(
                              (s) => DropdownMenuItem<int>(
                                value: s['id'] as int?,
                                child: Text((s['shop_name'] as String?) ?? 'Shop'),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) => setDialogState(() => shopId = value),
                        decoration: const InputDecoration(labelText: 'Shop'),
                      ),
                    if (!isEdit) const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Stock qty'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: status,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                        DropdownMenuItem(value: 'out_of_stock', child: Text('Out of stock')),
                      ],
                      onChanged: (value) => setDialogState(() => status = value ?? status),
                      decoration: const InputDecoration(labelText: 'Status'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final price = double.tryParse(priceController.text.trim());
                    final stock = int.tryParse(stockController.text.trim());
                    if (name.isEmpty || price == null || stock == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name, price, and stock are required.')),
                      );
                      return;
                    }
                    try {
                      if (isEdit) {
                        await ApiClient.instance.patchJson(
                          'seller/products/${existing!['id']}',
                          body: {
                            'name': name,
                            'description': descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            'price': price,
                            'stock_qty': stock,
                            'status': status,
                          },
                        );
                      } else {
                        await ApiClient.instance.postJson(
                          'seller/products',
                          body: {
                            'shop_id': shopId,
                            'name': name,
                            'description': descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            'price': price,
                            'stock_qty': stock,
                            'status': status,
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
    priceController.dispose();
    stockController.dispose();

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
      return const _NotAuthorizedScreen(title: 'My Products');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            onPressed: _openEditor,
            icon: const Icon(Icons.add),
            tooltip: 'Add product',
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
            if (!_loading && _error == null && _items.isEmpty) _EmptyCard(isDark: isDark, message: 'No products yet.'),
            if (!_loading && _error == null)
              ..._items.map((p) {
                final name = (p['name'] as String?) ?? 'Product';
                final price = (p['price'] as String?) ?? '';
                final stock = p['stock_qty'];
                final status = (p['status'] as String?) ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryColor),
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
                                  if (price.trim().isNotEmpty) 'Price: $price',
                                  if (stock != null) 'Stock: $stock',
                                  if (status.trim().isNotEmpty) status.trim(),
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
                              _openEditor(existing: p);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
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
            'Could not load products',
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
          Icon(Icons.inventory_2_outlined, color: isDark ? Colors.white54 : Colors.black45),
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
