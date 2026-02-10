import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/shimmer_box.dart';
import 'service_detail_screen.dart';
import 'service_requests_screen.dart';

class ServicesHomeScreen extends StatefulWidget {
  const ServicesHomeScreen({super.key});

  @override
  State<ServicesHomeScreen> createState() => _ServicesHomeScreenState();
}

class _ServicesHomeScreenState extends State<ServicesHomeScreen> {
  int? _categoryId;
  String _query = '';
  final _searchController = TextEditingController();

  List<_CategoryItem> _categoryGridItems(
    List<SmartlinkServiceCategory> categories,
  ) {
    return [
      const _CategoryItem.all(),
      ...categories.take(5).map(
            (c) => _CategoryItem(
              id: c.id,
              label: c.name,
              icon: _iconFor(c.icon),
            ),
          ),
    ];
  }

  IconData _iconFor(String value) {
    return switch (value) {
      'cleaning_services' => Icons.cleaning_services_outlined,
      'plumbing' => Icons.plumbing_outlined,
      'electric_bolt' => Icons.electric_bolt_outlined,
      'ac_unit' => Icons.ac_unit_outlined,
      'spa' => Icons.spa_outlined,
      _ => Icons.home_repair_service_outlined,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ServicesProvider>();
    final categories = provider.categories;
    final services = provider.services.where((s) {
      final matchesCategory = _categoryId == null || s.categoryId == _categoryId;
      final q = _query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          s.title.toLowerCase().contains(q) ||
          s.description.toLowerCase().contains(q) ||
          s.merchant.fullName.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('On-site Services'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ServiceRequestsScreen()),
            ),
            icon: const Icon(Icons.receipt_long_outlined, size: 18),
            label: const Text('My requests'),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<ServicesProvider>().load(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Protected payment',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Provider contact + full address stay locked until payment is held.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    height: 1.35,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search services, providers…',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _CategoryGrid(
              items: _categoryGridItems(categories),
              selectedId: _categoryId,
              onSelected: (id) => setState(() => _categoryId = id),
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: provider.isLoading
                  ? const _ServicesSkeletonList()
                  : services.isEmpty
                      ? _EmptyState(isDark: isDark)
                      : Column(
                          key: const ValueKey('services_list'),
                          children: services.map((s) => _ServiceCard(service: s)).toList(growable: false),
                        ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}

class _ServicesSkeletonList extends StatelessWidget {
  const _ServicesSkeletonList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: List.generate(
        5,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 16, width: 220)),
                  SizedBox(width: 10),
                  ShimmerBox(height: 28, width: 72, borderRadius: BorderRadius.all(Radius.circular(999))),
                ],
              ),
              SizedBox(height: 12),
              ShimmerBox(height: 12, width: 280),
              SizedBox(height: 8),
              ShimmerBox(height: 12, width: 240),
              SizedBox(height: 14),
              ShimmerBox(height: 12, width: 200),
              SizedBox(height: 14),
              Row(
                children: [
                  ShimmerBox(height: 26, width: 110, borderRadius: BorderRadius.all(Radius.circular(999))),
                  SizedBox(width: 10),
                  ShimmerBox(height: 26, width: 90, borderRadius: BorderRadius.all(Radius.circular(999))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final int? id;
  final String label;
  final IconData icon;

  const _CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
  });

  const _CategoryItem.all()
      : id = null,
        label = 'All',
        icon = Icons.apps_outlined;
}

class _CategoryGrid extends StatelessWidget {
  final List<_CategoryItem> items;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  const _CategoryGrid({
    required this.items,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          final selected = selectedId == item.id;

          return InkWell(
            onTap: () => onSelected(item.id),
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primaryColor.withValues(
                        alpha: isDark ? 0.20 : 0.10,
                      )
                    : (isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF3F4F6)),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? AppTheme.primaryColor.withValues(alpha: 0.30)
                      : (isDark
                          ? const Color(0xFF111827)
                          : const Color(0xFFE5E7EB)),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: 24,
                    color: selected
                        ? AppTheme.primaryColor
                        : (isDark ? Colors.white : AppTheme.textMain),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppTheme.textMain,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('services_empty'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 54,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          const SizedBox(height: 10),
          Text(
            'No services found',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another keyword or switch category.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final SmartlinkService service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final merchant = service.merchant;
    final rating = merchant.ratingAvg;
    final coverage = merchant.coverageAreas.isEmpty ? null : merchant.coverageAreas.first;
    final coverageLabel = coverage == null
        ? null
        : [
            coverage['area'],
            coverage['city'],
            coverage['state'],
          ].whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).join(', ');

    String initialsFor(String name) {
      final parts = name.trim().split(RegExp(r'\\s+')).where((p) => p.isNotEmpty).toList();
      if (parts.isEmpty) return 'S';
      final first = parts.first.isEmpty ? '' : parts.first[0];
      final second = parts.length > 1 ? (parts.last.isEmpty ? '' : parts.last[0]) : '';
      return (first + second).toUpperCase();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ServiceDetailScreen(serviceId: service.id)),
        ),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.22 : 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            initialsFor(merchant.fullName),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ),
                      ),
                      if (merchant.identityVerified)
                        const Positioned(
                          right: -4,
                          bottom: -4,
                          child: Icon(Icons.verified, size: 18, color: AppTheme.primaryColor),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          merchant.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (rating != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isDark ? 0.08 : 1.0),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                service.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : Colors.black54,
                      height: 1.35,
                    ),
              ),
              if (coverageLabel != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        coverageLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  _Pill(
                    icon: Icons.request_quote_outlined,
                    label: service.pricingType == 'quote' ? 'Quote-based' : service.pricingType,
                  ),
                  const SizedBox(width: 10),
                  if (merchant.trusted)
                    const _Pill(icon: Icons.verified_user_outlined, label: 'Trusted'),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: isDark ? Colors.white60 : Colors.black45),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
