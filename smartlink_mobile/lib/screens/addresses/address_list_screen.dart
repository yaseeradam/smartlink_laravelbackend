import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/address_provider.dart';
import 'address_edit_screen.dart';

class AddressListArgs {
  final bool selectionMode;
  const AddressListArgs({required this.selectionMode});
}

class AddressListScreen extends StatelessWidget {
  final bool selectionMode;

  const AddressListScreen({super.key, this.selectionMode = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final addresses = context.watch<AddressProvider>().items;
    final loaded = context.watch<AddressProvider>().isLoaded;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(selectionMode ? 'Choose address' : 'My addresses'),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddressEditScreen()),
            ),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: !loaded
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 56,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'No addresses yet',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Add a delivery address to make checkout smoother.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddressEditScreen()),
                          ),
                          child: const Text('Add address'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: addresses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final a = addresses[index];
                    final title = (a.label?.trim().isNotEmpty ?? false) ? a.label!.trim() : 'Address';
                    final subtitle = [
                      a.addressText,
                      if ((a.city?.isNotEmpty ?? false) || (a.state?.isNotEmpty ?? false))
                        '${a.city ?? ''}${(a.city?.isNotEmpty ?? false) && (a.state?.isNotEmpty ?? false) ? ', ' : ''}${a.state ?? ''}',
                    ].where((e) => e.trim().isNotEmpty).join('\n');

                    return Container(
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
                        border: a.isDefault
                            ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 1.5)
                            : null,
                      ),
                      child: ListTile(
                        onTap: () async {
                          await context.read<AddressProvider>().setDefault(a.id);
                          if (!context.mounted) return;
                          if (selectionMode) {
                            Navigator.pop(context);
                          }
                        },
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.place_outlined, color: AppTheme.primaryColor),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            if (a.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Default',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                                height: 1.35,
                              ),
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AddressEditScreen(address: a)),
                              );
                            } else if (value == 'delete') {
                              await context.read<AddressProvider>().remove(a.id);
                            } else if (value == 'default') {
                              await context.read<AddressProvider>().setDefault(a.id);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'default', child: Text('Set default')),
                            const PopupMenuDivider(),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
