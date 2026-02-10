import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/zone_provider.dart';

enum ZonePickerMode { home, operational }

class ZonePickerArgs {
  final ZonePickerMode mode;
  const ZonePickerArgs({required this.mode});
}

class ZonePickerScreen extends StatefulWidget {
  final ZonePickerMode mode;

  const ZonePickerScreen({super.key, this.mode = ZonePickerMode.home});

  @override
  State<ZonePickerScreen> createState() => _ZonePickerScreenState();
}

class _ZonePickerScreenState extends State<ZonePickerScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zoneProvider = context.watch<ZoneProvider>();
    final isOperational = widget.mode == ZonePickerMode.operational;

    final zones = zoneProvider.zones.where((z) {
      if (_query.isEmpty) return true;
      return z.name.toLowerCase().contains(_query.toLowerCase());
    }).toList(growable: false);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(isOperational ? 'Operational zone' : 'Home zone'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search zones',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isOperational
                        ? 'Operational zone is required for Seller/Rider KYC.'
                        : 'Your zone controls which storefronts and riders you see first.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.35,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...zones.map(
            (z) {
              final isSelected = isOperational
                  ? zoneProvider.operationalZone?.id == z.id
                  : zoneProvider.selectedZone?.id == z.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
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
                  border: isSelected
                      ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.5), width: 1.5)
                      : null,
                ),
                child: ListTile(
                  onTap: () async {
                    if (isOperational) {
                      await context.read<ZoneProvider>().setOperationalZone(z);
                    } else {
                      await context.read<ZoneProvider>().setSelectedZone(z);
                    }
                    if (!context.mounted) return;
                    Navigator.pop(context);
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
                  title: Text(
                    z.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  subtitle: Text(
                    isSelected ? 'Selected' : 'Tap to select',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? AppTheme.primaryColor
                              : (isDark ? Colors.white70 : Colors.black54),
                        ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                      : const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
