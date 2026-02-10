import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_role.dart';
import '../../providers/auth_provider.dart';

class MerchantCoverageAreasScreen extends StatefulWidget {
  const MerchantCoverageAreasScreen({super.key});

  @override
  State<MerchantCoverageAreasScreen> createState() => _MerchantCoverageAreasScreenState();
}

class _MerchantCoverageAreasScreenState extends State<MerchantCoverageAreasScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.getJson('merchant/coverage-areas');
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

  Future<void> _openEditor({Map<String, dynamic>? existing}) async {
    final isEdit = existing != null;
    final stateController = TextEditingController(text: (existing?['state'] as String?) ?? '');
    final cityController = TextEditingController(text: (existing?['city'] as String?) ?? '');
    final areaController = TextEditingController(text: (existing?['area'] as String?) ?? '');
    String coverageType = (existing?['coverage_type'] as String?) ?? 'local';
    bool saving = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Edit coverage area' : 'Add coverage area'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: stateController,
                      decoration: const InputDecoration(labelText: 'State'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: areaController,
                      decoration: const InputDecoration(labelText: 'Area'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: coverageType,
                      items: const [
                        DropdownMenuItem(value: 'local', child: Text('Local')),
                        DropdownMenuItem(value: 'state', child: Text('State')),
                        DropdownMenuItem(value: 'nationwide', child: Text('Nationwide')),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => coverageType = value);
                      },
                      decoration: const InputDecoration(labelText: 'Coverage type'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          final state = stateController.text.trim();
                          if (state.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('State is required.')),
                            );
                            return;
                          }

                          setDialogState(() => saving = true);
                          final city = cityController.text.trim();
                          final area = areaController.text.trim();

                          try {
                            if (isEdit) {
                              await ApiClient.instance.patchJson(
                                'merchant/coverage-areas/${existing!['id']}',
                                body: {
                                  'state': state,
                                  'city': city.isEmpty ? null : city,
                                  'area': area.isEmpty ? null : area,
                                  'coverage_type': coverageType,
                                },
                              );
                            } else {
                              await ApiClient.instance.postJson(
                                'merchant/coverage-areas',
                                body: {
                                  'state': state,
                                  'city': city.isEmpty ? null : city,
                                  'area': area.isEmpty ? null : area,
                                  'coverage_type': coverageType,
                                },
                              );
                            }
                            if (!mounted) return;
                            Navigator.pop(context, true);
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            setDialogState(() => saving = false);
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

    stateController.dispose();
    cityController.dispose();
    areaController.dispose();

    if (result == true) {
      await _load();
    }
  }

  Future<void> _deleteArea(Object id) async {
    try {
      await ApiClient.instance.dio.delete('merchant/coverage-areas/$id');
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
      return const _NotAuthorizedScreen(title: 'Coverage areas');
    }

    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Coverage areas')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_loading) const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator())),
            if (!_loading && _error != null) _ErrorCard(message: _error!, isDark: isDark, onRetry: _load),
            if (!_loading && _error == null && _items.isEmpty) _EmptyCard(isDark: isDark, message: 'No coverage areas yet.'),
            if (!_loading && _error == null)
              ..._items.map((area) {
                final id = area['id'];
                final state = (area['state'] as String?) ?? '';
                final city = (area['city'] as String?) ?? '';
                final locality = (area['area'] as String?) ?? '';
                final coverageType = (area['coverage_type'] as String?) ?? '';

                final subtitleParts = [
                  if (state.trim().isNotEmpty) state.trim(),
                  if (city.trim().isNotEmpty) city.trim(),
                  if (locality.trim().isNotEmpty) locality.trim(),
                  if (coverageType.trim().isNotEmpty) coverageType.trim(),
                ];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: outline),
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
                                state.isEmpty ? 'Coverage area' : state,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              if (subtitleParts.isNotEmpty) const SizedBox(height: 4),
                              if (subtitleParts.isNotEmpty)
                                Text(
                                  subtitleParts.join(' | '),
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
                              _openEditor(existing: area);
                            } else if (value == 'delete' && id != null) {
                              _deleteArea(id);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          icon: Icon(Icons.more_horiz_rounded, color: isDark ? Colors.white60 : Colors.black45),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 6),
            ElevatedButton.icon(
              onPressed: _openEditor,
              icon: const Icon(Icons.add),
              label: const Text('Add coverage area'),
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
            'Could not load coverage areas',
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
          Icon(Icons.map_outlined, color: isDark ? Colors.white54 : Colors.black45),
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
