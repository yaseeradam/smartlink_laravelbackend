import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../providers/cart_provider.dart';
import '../../providers/zone_provider.dart';
import '../../providers/auth_provider.dart';
import '../zones/zone_picker_screen.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/shop_card.dart';
import '../../widgets/common/shimmer_box.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _shops = [];
  String _selectedCategory = 'All';
  final PageController _promoController =
      PageController(viewportFraction: 0.92);
  int _promoIndex = 0;
  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'icon': Icons.apps},
    {'name': 'Groceries', 'icon': Icons.local_grocery_store},
    {'name': 'Phones', 'icon': Icons.smartphone_outlined},
    {'name': 'Electronics', 'icon': Icons.headphones_outlined},
    {'name': 'Fashion', 'icon': Icons.checkroom_outlined},
    {'name': 'Appliances', 'icon': Icons.kitchen_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _loadMarketplaceData();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketplaceData() async {
    setState(() => _isLoading = true);
    final String response =
        await rootBundle.loadString('assets/mock_data/products.json');
    final data = (json.decode(response) as List).cast<Map<String, dynamic>>();
    if (!mounted) return;

    // Group products by shop/seller
    final Map<String, Map<String, dynamic>> shopsMap = {};
    for (var product in data) {
      final sellerId = product['sellerId'] ?? 'unknown';
      if (!shopsMap.containsKey(sellerId)) {
        shopsMap[sellerId] = {
          'id': sellerId,
          'name': product['sellerName'] ?? 'Unknown Shop',
          'category': product['category'] ?? 'Retail',
          'location': product['sellerLocation'] ?? 'Lagos',
          'rating': 4.5 + (sellerId.hashCode % 5) / 10,
          'distance': (sellerId.hashCode % 30) / 10,
          'image':
              product['images']?[0] ?? 'https://via.placeholder.com/400x300',
          'trusted': true,
          'deliveryType': 'Pilot Delivery',
          'deliveryTime': '15-20 min',
        };
      }
    }

    setState(() {
      _products = data;
      _shops = shopsMap.values.toList();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'All') return _products;
    final categoryId = _selectedCategory.toLowerCase();
    return _products
        .where((p) => (p['category'] as String?) == categoryId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            _buildTopBar(isDark),

            // Main Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMarketplaceData,
                color: AppTheme.primaryColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.search),
                        borderRadius: BorderRadius.circular(16),
                        child: Ink(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.outlineDark
                                  : AppTheme.outlineLight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.22 : 0.06),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Search products and storefronts',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isDark
                                            ? Colors.white70
                                            : Colors.black54,
                                      ),
                                ),
                              ),
                              Icon(
                                Icons.tune,
                                size: 20,
                                color: isDark ? Colors.white60 : Colors.black45,
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildPromoCarousel(isDark),
                      const SizedBox(height: 18),

                      _buildCategoriesSection(isDark),
                      const SizedBox(height: 24),

                      _buildFlashDealsSection(isDark),
                      const SizedBox(height: 24),

                      _buildProductsSection(isDark),
                      const SizedBox(height: 24),

                      _buildFeaturedStorefrontsSection(isDark),
                      const SizedBox(height: 28),

                      _buildStorefrontsSection(isDark),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildTopBar(bool isDark) {
    final cartCount = context.watch<CartProvider>().itemCount;
    final zoneLabel = context.watch<ZoneProvider>().selectedZoneLabel;
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final displayName = ((user?['name'] as String?) ?? 'Guest').trim().isEmpty
        ? 'Guest'
        : ((user?['name'] as String?) ?? 'Guest').trim();

    String initialsFor(String name) {
      final parts = name
          .trim()
          .split(RegExp(r'\\s+'))
          .where((p) => p.isNotEmpty)
          .toList();
      if (parts.isEmpty) return 'S';

      String firstRune(String s) {
        if (s.isEmpty) return '';
        final iterator = s.runes.iterator..moveNext();
        return String.fromCharCode(iterator.current);
      }

      final first = firstRune(parts.first);
      final second = parts.length > 1 ? firstRune(parts.last) : '';
      return (first + second).toUpperCase();
    }

    return AnimatedContainer(
      duration: AppTheme.normalAnimation,
      curve: AppTheme.smoothCurve,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusLg),
          bottomRight: Radius.circular(AppTheme.radiusLg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, AppRouter.profile),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'profile_avatar',
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.15),
                              AppTheme.primaryColor.withValues(alpha: 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initialsFor(displayName),
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                              ),
                              if (auth.isPhoneVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified,
                                    size: 18, color: AppTheme.primaryColor),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Location Picker
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.zones,
                      arguments: const ZonePickerArgs(mode: ZonePickerMode.home),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  splashColor: AppTheme.primaryColor.withValues(alpha: 0.08),
                  highlightColor: AppTheme.primaryColor.withValues(alpha: 0.04),
                  child: AnimatedContainer(
                    duration: AppTheme.fastAnimation,
                    curve: AppTheme.smoothCurve,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isDark 
                          ? AppTheme.primaryColor.withValues(alpha: 0.08)
                          : AppTheme.primaryColor.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on,
                            color: AppTheme.primaryColor, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            zoneLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryColor,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.expand_more,
                          size: 18,
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Cart
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, AppRouter.cart),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              splashColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              highlightColor: AppTheme.primaryColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 26,
                      color: isDark ? Colors.white : AppTheme.textMain,
                    ),
                    if (cartCount > 0)
                      Positioned(
                        right: -8,
                        top: -8,
                        child: AnimatedScale(
                          scale: 1.0,
                          duration: AppTheme.fastAnimation,
                          curve: AppTheme.bounceCurve,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                              border: Border.all(
                                color: isDark
                                    ? AppTheme.surfaceDark
                                    : Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              cartCount > 9 ? '9+' : '$cartCount',
                              style:
                                  Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 10,
                                      ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(bool isDark) {
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Explore',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.search),
              child: Text(
                'View all',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final label = (category['name'] as String?) ?? '';
              final isSelected = label == _selectedCategory;

              return InkWell(
                onTap: () => setState(() => _selectedCategory = label),
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor
                            .withValues(alpha: isDark ? 0.20 : 0.10)
                        : (isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF3F4F6)),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
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
                        category['icon'] as IconData? ??
                            Icons.category_outlined,
                        size: 24,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : (isDark ? Colors.white : AppTheme.textMain),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
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
        ),
      ],
    );
  }

  Widget _buildProductsSection(bool isDark) {
    final items = _filteredProducts.take(6).toList();
    final money = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedCategory == 'All'
                  ? 'Popular picks'
                  : 'Popular in $_selectedCategory',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.feed),
              child: Text(
                'See more',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isLoading
              ? GridView.count(
                  key: const ValueKey('products_skeleton'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.62,
                  children: const [
                    _ProductSkeletonCard(),
                    _ProductSkeletonCard(),
                    _ProductSkeletonCard(),
                    _ProductSkeletonCard(),
                  ],
                )
              : GridView.builder(
                  key: const ValueKey('products_grid'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.62,
                  ),
                  itemBuilder: (context, index) {
                    return _HomeProductCard(
                      product: items[index],
                      isDark: isDark,
                      money: money,
                      onAdd: () {
                        context.read<CartProvider>().addItem(items[index]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')),
                        );
                      },
                      onTap: () => Navigator.pushNamed(
                          context, AppRouter.productDetail,
                          arguments: items[index]),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPromoCarousel(bool isDark) {
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;
    final promos = _promoItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Today’s deals',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.feed),
              child: Text(
                'View offers',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 164,
          child: PageView.builder(
            controller: _promoController,
            itemCount: promos.length,
            onPageChanged: (index) => setState(() => _promoIndex = index),
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _PromoBannerCard(
                  isDark: isDark,
                  outline: outline,
                  title: promo.title,
                  subtitle: promo.subtitle,
                  cta: promo.cta,
                  imageUrl: promo.imageUrl,
                  gradient: promo.gradient,
                  onTap: promo.onTap,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(promos.length, (i) {
            final active = i == _promoIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.primaryColor
                    : (isDark ? Colors.white24 : Colors.black12),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFlashDealsSection(bool isDark) {
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;
    final items = _filteredProducts.take(10).toList();
    final money = NumberFormat.currency(symbol: '₦', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Flash deals',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444)
                    .withValues(alpha: isDark ? 0.18 : 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.28)),
              ),
              child: Text(
                'Ends soon',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: const Color(0xFFEF4444),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.feed),
              child: Text(
                'See all',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 176,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _isLoading
                ? ListView.separated(
                    key: const ValueKey('flash_skeleton'),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: outline),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(
                              height: 92,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20))),
                          SizedBox(height: 10),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerBox(height: 12, width: 110),
                                SizedBox(height: 10),
                                ShimmerBox(height: 14, width: 80),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    key: const ValueKey('flash_list'),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final product = items[index];
                      return _FlashDealCard(
                        isDark: isDark,
                        outline: outline,
                        product: product,
                        money: money,
                        discountPercent: _discountForProduct(product),
                        onTap: () => Navigator.pushNamed(
                            context, AppRouter.productDetail,
                            arguments: product),
                        onAdd: () {
                          context.read<CartProvider>().addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedStorefrontsSection(bool isDark) {
    final outline = isDark ? AppTheme.outlineDark : AppTheme.outlineLight;
    final items = _shops.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Featured storefronts',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.search),
              child: Text(
                'Browse',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 104,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _isLoading
                ? ListView.separated(
                    key: const ValueKey('featured_shops_skeleton'),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => Container(
                      width: 220,
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: outline),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ShimmerBox(
                                height: 56,
                                width: 56,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18))),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ShimmerBox(height: 12, width: 120),
                                  SizedBox(height: 10),
                                  ShimmerBox(height: 10, width: 90),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    key: const ValueKey('featured_shops_list'),
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final shop = items[index];
                      return _FeaturedShopCard(
                        isDark: isDark,
                        outline: outline,
                        shop: shop,
                        onTap: () => Navigator.pushNamed(
                            context, AppRouter.shopDetail,
                            arguments: shop),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  int _discountForProduct(Map<String, dynamic> product) {
    final id = (product['id'] as String?) ?? '';
    final hash = id.hashCode.abs();
    final discount = 10 + (hash % 45);
    return math.min(discount, 60);
  }

  List<_PromoBannerData> _promoItems() {
    final productImages = _products
        .map((p) => (p['images'] is List)
            ? (p['images'] as List).cast<String>()
            : <String>[])
        .where((imgs) => imgs.isNotEmpty)
        .map((imgs) => imgs.first)
        .toList();

    String img(int i) =>
        productImages.isEmpty ? '' : productImages[i % productImages.length];

    return [
      _PromoBannerData(
        title: 'Up to 40% off',
        subtitle: 'Flash deals across popular categories.',
        cta: 'Shop deals',
        imageUrl: img(0),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
        ),
        onTap: () => Navigator.pushNamed(context, AppRouter.feed),
      ),
      _PromoBannerData(
        title: 'Trusted storefronts',
        subtitle: 'Shop with escrow-backed payments.',
        cta: 'Browse stores',
        imageUrl: img(1),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0EA5E9), Color(0xFF22C55E)],
        ),
        onTap: () => Navigator.pushNamed(context, AppRouter.search),
      ),
      _PromoBannerData(
        title: 'Fast delivery',
        subtitle: 'Get items delivered in minutes.',
        cta: 'See picks',
        imageUrl: img(2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF16A34A)],
        ),
        onTap: () => Navigator.pushNamed(context, AppRouter.feed),
      ),
    ];
  }

  Widget _buildStorefrontsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Storefronts near you',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRouter.search),
              child: Text(
                'See all',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _isLoading
              ? const Column(
                  key: ValueKey('shops_skeleton'),
                  children: [
                    _ShopSkeletonCard(),
                    SizedBox(height: 20),
                    _ShopSkeletonCard(),
                  ],
                )
              : ListView.separated(
                  key: const ValueKey('shops_list'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _shops.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 20),
                  itemBuilder: (context, index) {
                    final shop = _shops[index];
                    return InkWell(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRouter.shopDetail,
                        arguments: shop,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: ShopCard(shop: shop),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ProductSkeletonCard extends StatelessWidget {
  const _ProductSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
              height: 112,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 14, width: 140),
                SizedBox(height: 8),
                ShimmerBox(height: 12, width: 110),
                SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: ShimmerBox(height: 16, width: 80)),
                    SizedBox(width: 10),
                    ShimmerBox(
                        height: 36,
                        width: 36,
                        borderRadius: BorderRadius.all(Radius.circular(14))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopSkeletonCard extends StatelessWidget {
  const _ShopSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
              height: 192,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 16, width: 180),
                SizedBox(height: 10),
                ShimmerBox(height: 12, width: 160),
                SizedBox(height: 14),
                ShimmerBox(height: 12, width: 220),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isDark;
  final NumberFormat money;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _HomeProductCard({
    required this.product,
    required this.isDark,
    required this.money,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final title = (product['title'] as String?) ?? '';
    final seller = (product['sellerName'] as String?) ?? '';
    final price = (product['price'] as num?)?.toDouble() ?? 0.0;
    final rating = (product['rating'] as num?)?.toDouble();
    final images = (product['images'] is List)
        ? (product['images'] as List).cast<String>()
        : <String>[];
    final imageUrl = images.isEmpty ? '' : images.first;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 112,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerBox(
                      height: 112,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 112,
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF3F4F6),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined),
                    ),
                  ),
                  if (rating != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      seller,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              money.format(price),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onAdd,
                          borderRadius: BorderRadius.circular(14),
                          child: Ink(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor
                                  .withValues(alpha: isDark ? 0.25 : 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.add,
                                color: AppTheme.primaryColor, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromoBannerData {
  final String title;
  final String subtitle;
  final String cta;
  final String imageUrl;
  final Gradient gradient;
  final VoidCallback onTap;

  const _PromoBannerData({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.imageUrl,
    required this.gradient,
    required this.onTap,
  });
}

class _PromoBannerCard extends StatelessWidget {
  final bool isDark;
  final Color outline;
  final String title;
  final String subtitle;
  final String cta;
  final String imageUrl;
  final Gradient gradient;
  final VoidCallback onTap;

  const _PromoBannerCard({
    required this.isDark,
    required this.outline,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.imageUrl,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: gradient),
                ),
              ),
              if (imageUrl.isNotEmpty)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.20,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.88),
                                  height: 1.25,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.22)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  cta,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.arrow_forward,
                                    size: 16, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.22)),
                      ),
                      child: const Icon(Icons.local_mall_outlined,
                          color: Colors.white),
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

class _FlashDealCard extends StatelessWidget {
  final bool isDark;
  final Color outline;
  final Map<String, dynamic> product;
  final NumberFormat money;
  final int discountPercent;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _FlashDealCard({
    required this.isDark,
    required this.outline,
    required this.product,
    required this.money,
    required this.discountPercent,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final title = (product['title'] as String?) ?? '';
    final price = (product['price'] as num?)?.toDouble() ?? 0;
    final oldPrice = (price <= 0)
        ? 0
        : (price / (1 - (discountPercent / 100))).ceilToDouble();
    final rating = (product['rating'] as num?)?.toDouble();
    final images = (product['images'] is List)
        ? (product['images'] as List).cast<String>()
        : <String>[];
    final imageUrl = images.isEmpty ? '' : images.first;

    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.05),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 92,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ShimmerBox(
                        height: 92,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 92,
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF3F4F6),
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Text(
                          '-$discountPercent%',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                      ),
                    ),
                    if (rating != null)
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: AppTheme.primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  money.format(price),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                if (oldPrice > price && oldPrice > 0)
                                  Text(
                                    money.format(oldPrice),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black45,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: onAdd,
                            borderRadius: BorderRadius.circular(14),
                            child: Ink(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: isDark ? 0.25 : 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.add,
                                  color: AppTheme.primaryColor, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedShopCard extends StatelessWidget {
  final bool isDark;
  final Color outline;
  final Map<String, dynamic> shop;
  final VoidCallback onTap;

  const _FeaturedShopCard({
    required this.isDark,
    required this.outline,
    required this.shop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = (shop['name'] as String?) ?? 'Shop';
    final category = (shop['category'] as String?) ?? 'Retail';
    final rating = (shop['rating'] as double?);
    final imageUrl = (shop['image'] as String?) ?? '';

    return SizedBox(
      width: 240,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerBox(
                      height: 56,
                      width: 56,
                      borderRadius: BorderRadius.all(Radius.circular(18)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      color: isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF3F4F6),
                      child: const Icon(Icons.storefront_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                            ),
                          ),
                          if (rating != null) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star,
                                size: 14, color: AppTheme.primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: isDark ? Colors.white60 : Colors.black45),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
