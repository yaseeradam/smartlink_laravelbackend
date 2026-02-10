import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatting.dart';
import '../../providers/cart_provider.dart';
import '../../providers/feed_provider.dart';
import '../../providers/zone_provider.dart';
import '../../widgets/common/shimmer_box.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  FeedScope _scope = FeedScope.auto;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final zoneLabel = context.watch<ZoneProvider>().selectedZoneLabel;
    final provider = context.watch<FeedProvider>();

    final type = switch (_tabController.index) {
      0 => FeedType.nearYou,
      1 => FeedType.inYourState,
      2 => FeedType.acrossNigeria,
      _ => FeedType.forYou,
    };

    final items = provider.items(
      type: type,
      zoneLabel: zoneLabel,
      scope: _scope,
      limit: 100,
    );

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (_) => setState(() {}),
                indicator: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                dividerColor: Colors.transparent,
                labelColor: isDark ? Colors.white : AppTheme.textMain,
                unselectedLabelColor: isDark ? Colors.white70 : AppTheme.textSecondary,
                tabs: const [
                  Tab(text: 'Near you'),
                  Tab(text: 'State'),
                  Tab(text: 'National'),
                  Tab(text: 'For you'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<FeedProvider>().load(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _TopBar(zoneLabel: zoneLabel, showScope: type == FeedType.forYou, scope: _scope, onScopeChanged: (s) => setState(() => _scope = s)),
            const SizedBox(height: 12),
            if (provider.isLoading)
              const _FeedSkeletonList()
            else if (items.isEmpty)
              _EmptyState(isDark: isDark)
            else
              ...items.map((p) => _ProductCard(product: p)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FeedSkeletonList extends StatelessWidget {
  const _FeedSkeletonList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: List.generate(
        6,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
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
          child: const Row(
            children: [
              ShimmerBox(height: 84, width: 84, borderRadius: BorderRadius.all(Radius.circular(16))),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 14, width: 220),
                    SizedBox(height: 10),
                    ShimmerBox(height: 12, width: 160),
                    SizedBox(height: 10),
                    ShimmerBox(height: 12, width: 120),
                    SizedBox(height: 14),
                    ShimmerBox(height: 16, width: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String zoneLabel;
  final bool showScope;
  final FeedScope scope;
  final ValueChanged<FeedScope> onScopeChanged;

  const _TopBar({
    required this.zoneLabel,
    required this.showScope,
    required this.scope,
    required this.onScopeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              zoneLabel,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          if (showScope)
            DropdownButtonHideUnderline(
              child: DropdownButton<FeedScope>(
                value: scope,
                onChanged: (v) => v == null ? null : onScopeChanged(v),
                items: const [
                  DropdownMenuItem(value: FeedScope.auto, child: Text('Auto')),
                  DropdownMenuItem(value: FeedScope.local, child: Text('Local')),
                  DropdownMenuItem(value: FeedScope.state, child: Text('State')),
                  DropdownMenuItem(value: FeedScope.national, child: Text('National')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = (product['title'] as String?) ?? '';
    final seller = (product['sellerName'] as String?) ?? '';
    final location = (product['sellerLocation'] as String?) ?? '';
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final rating = (product['rating'] as num?)?.toDouble();
    final images = (product['images'] is List) ? (product['images'] as List).cast<String>() : <String>[];
    final imageUrl = images.isEmpty ? '' : images.first;

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
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, AppRouter.productDetail, arguments: product),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerBox(
                      width: 84,
                      height: 84,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                      errorWidget: (_, __, ___) => Container(
                        width: 84,
                        height: 84,
                        color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                        child: const Icon(Icons.image_outlined),
                      ),
                    ),
                    if (rating != null)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 14, color: AppTheme.primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppTheme.textMain,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            seller,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              Formatting.naira(price, decimalDigits: 0),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<CartProvider>().addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')),
                            );
                          },
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(Icons.feed_outlined, size: 48, color: isDark ? Colors.white54 : Colors.black45),
          const SizedBox(height: 10),
          Text(
            'Nothing here yet',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Try switching scope or zone.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
          ),
        ],
      ),
    );
  }
}
