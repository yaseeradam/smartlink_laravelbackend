import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class SellerCategoriesScreen extends StatefulWidget {
  const SellerCategoriesScreen({super.key});

  @override
  State<SellerCategoriesScreen> createState() => _SellerCategoriesScreenState();
}

class _SellerCategoriesScreenState extends State<SellerCategoriesScreen> {
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
      final res = await ApiClient.instance.getJson('seller/categories');
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
    final sortController = TextEditingController(text: (existing?['sort_order'] ?? 0).toString());
    String status = (existing?['status'] as String?) ?? 'active';
    int? shopId = existing?['shop_id'] as int?;
    shopId ??= _shops.isNotEmpty ? _shops.first['id'] as int? : null;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit category' : 'Create category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_shops.isNotEmpty)
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
                    const SizedBox(height: 10),
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
                      controller: sortController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Sort order'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: status,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      ],
                      onChanged: (value) => setDialogState(() => status = value ?? 'active'),
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
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name is required.')),
                      );
                      return;
                    }
                    final sort = int.tryParse(sortController.text.trim()) ?? 0;
                    try {
                      if (isEdit) {
                        await ApiClient.instance.patchJson(
                          'seller/categories/${existing!['id']}',
                          body: {
                            'name': name,
                            'description': descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            'sort_order': sort,
                            'status': status,
                          },
                        );
                      } else {
                        await ApiClient.instance.postJson(
                          'seller/categories',
                          body: {
                            'shop_id': shopId,
                            'name': name,
                            'description': descriptionController.text.trim().isEmpty
                                ? null
                                : descriptionController.text.trim(),
                            'sort_order': sort,
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
    sortController.dispose();

    if (result == true) {
      await _load();
    }
  }

  Future<void> _deleteCategory(Object id) async {
    try {
      await ApiClient.instance.dio.delete('seller/categories/$id');
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final role = AppRoleX.fromApiValue(auth.currentUser?['role'] as String?);

    if (role != AppRole.merchant) {
      return const _NotAuthorizedScreen(title: 'Seller categories');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Categories')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null && _items.isEmpty) _EmptyCard(isDark: isDark, message: 'No categories yet.'),
            if (!_loading && _error == null)
              ..._items.map((c) {
                final id = c['id'];
                final name = (c['name'] as String?) ?? 'Category';
                final count = c['products_count'];
                final status = (c['status'] as String?) ?? '';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: outline),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.grid_view_outlined, color: AppTheme.primaryColor),
                      ),
                      title: Text(
                        name,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text(
                        [
                          if (count != null) '$count products',
                          if (status.trim().isNotEmpty) status.trim(),
                        ].join(' | '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _openEditor(existing: c);
                          } else if (value == 'delete' && id != null) {
                            _deleteCategory(id);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                        icon: const Icon(Icons.more_horiz_rounded),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: _openEditor,
              icon: const Icon(Icons.add),
              label: const Text('Create category'),
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
            'Could not load categories',
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
          Icon(Icons.category_outlined, color: isDark ? Colors.white54 : Colors.black45),
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
