# Screen Migration Guide - Applying Smooth Design Improvements

This guide shows you exactly how to apply the new smooth design improvements to all screens in the SmartLink app.

## ✅ Already Updated Screens

The following screens already have smooth designs and don't need updates:
- ✓ **Splash Screen** - Has glassmorphism, blur effects, and smooth animations
- ✓ **Onboarding Screen** - Beautiful page transitions and glassmorphic cards
- ✓ **Auth & Register Screens** - Gradient backgrounds and smooth form animations
- ✓ **Wallet Screen** (JUST UPDATED) - Demonstrates the migration pattern

## 🎯 Migration Pattern

Follow this pattern for every screen you update:

### Step 1: Add Imports

```dart
// Add these imports to every screen you update
import '../../widgets/common/fade_in_slide.dart';
import '../../widgets/common/smooth_button.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/animated_card.dart';
import '../../widgets/common/section_divider.dart';
import '../../widgets/common/smooth_badge.dart';
```

### Step 2: Wrap Body with GradientBackground

**Before:**
```dart
Scaffold(
  body: ListView(
    children: [
      // content
    ],
  ),
)
```

**After:**
```dart
Scaffold(
  body: GradientBackground(
    child: ListView(
      children: [
        // content
      ],
    ),
  ),
)
```

### Step 3: Add FadeInSlide to Main Elements

**Before:**
```dart
Column(
  children: [
    HeaderWidget(),
    ContentWidget(),
    FooterWidget(),
  ],
)
```

**After:**
```dart
Column(
  children: [
    FadeInSlide(
      delay: Duration(milliseconds: 100),
      child: HeaderWidget(),
    ),
    FadeInSlide(
      delay: Duration(milliseconds: 200),
      child: ContentWidget(),
    ),
    FadeInSlide(
      delay: Duration(milliseconds: 300),
      child: FooterWidget(),
    ),
  ],
)
```

### Step 4: Replace Containers with AnimatedCard

**Before:**
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
  ),
  child: ProductContent(),
)
```

**After:**
```dart
AnimatedCard(
  onTap: () => handleProductTap(),
  padding: EdgeInsets.all(AppTheme.spaceLg),
  child: ProductContent(),
)
```

### Step 5: Replace Buttons with SmoothButton

**Before:**
```dart
ElevatedButton(
  onPressed: onSubmit,
  child: Text('Submit'),
)
```

**After:**
```dart
SmoothButton(
  text: 'Submit',
  icon: Icons.check_circle_outline_rounded,
  onPressed: onSubmit,
  style: SmoothButtonStyle.primary,
)
```

### Step 6: Update Spacing to Use Theme Constants

**Before:**
```dart
const SizedBox(height: 16)
const EdgeInsets.all(20)
```

**After:**
```dart
const SizedBox(height: AppTheme.spaceLg)
const EdgeInsets.all(AppTheme.spaceXl)
```

### Step 7: Update Shadows to Use Theme Constants

**Before:**
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 10,
  offset: Offset(0, 4),
)
```

**After:**
```dart
// For cards and containers
boxShadow: isDark ? AppTheme.mediumShadowDark : AppTheme.mediumShadowLight,
```

### Step 8: Add Staggered Animations to Lists

**Before:**
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemCard(item: items[index]);
  },
)
```

**After:**
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return FadeInSlide(
      delay: Duration(milliseconds: 200 + (index * 50)),
      child: ItemCard(item: items[index]),
    );
  },
)
```

---

## 📱 Screen-Specific Examples

### Home Screen Pattern

```dart
class CustomerHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              FadeInSlide(
                delay: Duration(milliseconds: 100),
                child: TopBarWidget(),
              ),
              
              // Main content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {},
                  child: ListView(
                    padding: EdgeInsets.all(AppTheme.spaceXl),
                    children: [
                      // Search bar
                      FadeInSlide(
                        delay: Duration(milliseconds: 200),
                        child: SearchBarWidget(),
                      ),
                      
                      SizedBox(height: AppTheme.space2Xl),
                      
                      // Section title
                      FadeInSlide(
                        delay: Duration(milliseconds: 300),
                        child: SectionTitle('Featured'),
                      ),
                      
                      // Products grid
                      ...products.asMap().entries.map((entry) {
                        return FadeInSlide(
                          delay: Duration(milliseconds: 400 + (entry.key * 50)),
                          child: AnimatedCard(
                            margin: EdgeInsets.only(bottom: AppTheme.spaceMd),
                            onTap: () => navigateToProduct(entry.value),
                            child: ProductContent(entry.value),
                          ),
                        );
                      }),
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
```

### Profile Screen Pattern

```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: GradientBackground(
        child: ListView(
          padding: EdgeInsets.all(AppTheme.spaceXl),
          children: [
            // Profile header
            FadeInSlide(
              delay: Duration(milliseconds: 100),
              child: ProfileHeaderCard(),
            ),
            
            SizedBox(height: AppTheme.space2Xl),
            
            // Section divider
            FadeInSlide(
              delay: Duration(milliseconds: 200),
              child: SectionDivider(title: 'Account Settings'),
            ),
            
            SizedBox(height: AppTheme.spaceLg),
            
            // Settings items
            ...settingsItems.asMap().entries.map((entry) {
              return FadeInSlide(
                delay: Duration(milliseconds: 300 + (entry.key * 50)),
                child: AnimatedCard(
                  margin: EdgeInsets.only(bottom: AppTheme.spaceSm),
                  onTap: entry.value.onTap,
                  child: SettingsItem(entry.value),
                ),
              );
            }),
            
            SizedBox(height: AppTheme.space2Xl),
            
            // Logout button
            FadeInSlide(
              delay: Duration(milliseconds: 600),
              child: SmoothButton(
                text: 'Log Out',
                icon: Icons.logout_rounded,
                onPressed: handleLogout,
                style: SmoothButtonStyle.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Order Detail Screen Pattern

```dart
class OrderDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text('Order Details')),
      body: GradientBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppTheme.spaceXl),
                children: [
                  // Order status
                  FadeInSlide(
                    delay: Duration(milliseconds: 100),
                    child: OrderStatusCard(),
                  ),
                  
                  SizedBox(height: AppTheme.space2Xl),
                  
                  // Items
                  FadeInSlide(
                    delay: Duration(milliseconds: 200),
                    child: SectionDivider(title: 'Items'),
                  ),
                  
                  ...orderItems.asMap().entries.map((entry) {
                    return FadeInSlide(
                      delay: Duration(milliseconds: 300 + (entry.key * 50)),
                      child: OrderItemCard(entry.value),
                    );
                  }),
                ],
              ),
            ),
            
            // Bottom actions
            FadeInSlide(
              delay: Duration(milliseconds: 500),
              child: Container(
                padding: EdgeInsets.all(AppTheme.spaceLg),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  boxShadow: isDark ? AppTheme.largeShadowDark : AppTheme.largeShadowLight,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: Column(
                  children: [
                    SmoothButton(
                      text: 'Track Order',
                      icon: Icons.location_on_outlined,
                      onPressed: handleTrack,
                      style: SmoothButtonStyle.primary,
                    ),
                    SizedBox(height: AppTheme.spaceSm),
                    SmoothButton(
                      text: 'Contact Seller',
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: handleContact,
                      style: SmoothButtonStyle.secondary,
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
```

---

## 🎨 Component-Specific Patterns

### Alert/Warning Banners

**Before:**
```dart
Container(
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.orange.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Icon(Icons.warning, color: Colors.orange),
      SizedBox(width: 8),
      Text('Warning message'),
    ],
  ),
)
```

**After:**
```dart
Container(
  padding: EdgeInsets.all(AppTheme.spaceMd),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFFF59E0B).withValues(alpha: 0.15),
        Color(0xFFF59E0B).withValues(alpha: 0.08),
      ],
    ),
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    border: Border.all(
      color: Color(0xFFF59E0B).withValues(alpha: 0.3),
    ),
  ),
  child: Row(
    children: [
      Container(
        padding: EdgeInsets.all(AppTheme.spaceSm),
        decoration: BoxDecoration(
          color: Color(0xFFF59E0B).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
        ),
        child: Icon(
          Icons.warning_amber_rounded,
          color: Color(0xFFF59E0B),
          size: 20,
        ),
      ),
      SizedBox(width: AppTheme.spaceMd),
      Expanded(
        child: Text(
          'Warning message',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    ],
  ),
)
```

### Section Headers

**Before:**
```dart
Text(
  'Section Title',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
)
```

**After:**
```dart
Row(
  children: [
    Container(
      padding: EdgeInsets.all(AppTheme.spaceXs),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
      ),
      child: Icon(
        Icons.category_rounded,
        size: 16,
        color: AppTheme.primaryColor,
      ),
    ),
    SizedBox(width: AppTheme.spaceSm),
    Text(
      'Section Title',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    ),
  ],
)
```

### Empty States

**Before:**
```dart
Center(
  child: Column(
    children: [
      Icon(Icons.inbox, size: 48),
      Text('No items found'),
    ],
  ),
)
```

**After:**
```dart
Center(
  child: FadeInSlide(
    child: Container(
      padding: EdgeInsets.all(AppTheme.space3Xl),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.space2Xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.15),
                  AppTheme.primaryColor.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inbox_rounded,
              size: 48,
              color: AppTheme.primaryColor,
            ),
          ),
          SizedBox(height: AppTheme.spaceLg),
          Text(
            'No items found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: AppTheme.spaceSm),
          Text(
            'Start adding items to see them here',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    ),
  ),
)
```

---

## 📋 Screen Migration Checklist

Use this checklist for each screen you update:

### Pre-Migration
- [ ] Read the current screen code
- [ ] Identify all interactive elements (buttons, cards, lists)
- [ ] Note any existing animations
- [ ] Check if screen uses custom styling

### During Migration
- [ ] Add necessary imports
- [ ] Wrap body with `GradientBackground`
- [ ] Add `FadeInSlide` to main sections (stagger by 100-200ms)
- [ ] Replace `Container` with `AnimatedCard` for interactive items
- [ ] Replace `ElevatedButton` with `SmoothButton`
- [ ] Replace spacing values with `AppTheme` constants
- [ ] Update shadows to use `AppTheme` shadow constants
- [ ] Add staggered animations to lists (50ms per item)
- [ ] Update border radius to use `AppTheme` constants
- [ ] Add gradient backgrounds to important cards

### Post-Migration
- [ ] Test on light theme
- [ ] Test on dark theme
- [ ] Verify all animations are smooth
- [ ] Check tap feedback on all interactive elements
- [ ] Ensure proper spacing throughout
- [ ] Verify shadows look soft and natural

---

## 🎯 Priority Order for Migration

Migrate screens in this order for maximum visual impact:

### High Priority (User sees frequently)
1. ✅ **Wallet Screen** - DONE
2. **Customer Home Screen**
3. **Product Detail Screen**
4. **Cart Screen**
5. **Orders Screen**
6. **Profile Screen**

### Medium Priority
7. **Shop Detail Screen**
8. **Search Screen**
9. **Categories Screen**
10. **Feed Screen**
11. **Favorites Screen**
12. **Notifications Screen**

### Lower Priority
13. **Order Detail Screen**
14. **Order Tracking Screen**
15. **Merchant Screens**
16. **Rider Screens**
17. **Settings Screens**
18. **KYC Screens**

---

## ⚡ Quick Tips

1. **Start Small**: Begin with one screen, test thoroughly, then apply the pattern to others
2. **Delay Timing**: Use 100ms base delay + 50ms per item for staggered lists
3. **Shadows**: Use `softShadow` for small elements, `mediumShadow` for cards, `largeShadow` for modals
4. **Gradients**: Keep them subtle (max 2 colors with low alpha)
5. **Spacing**: Use the 7-level spacing system consistently
6. **Border Radius**: Stick to `radiusSm` (12px) for small, `radiusMd` (16px) for medium, `radiusLg` (20px) for large

---

## 🐛 Common Issues & Solutions

### Issue: Animations feel too slow
**Solution**: Reduce duration from 400ms to 300ms, or reduce delays

### Issue: Too many elements animating at once
**Solution**: Group animations or increase stagger delay to 100ms

### Issue: Shadows look harsh
**Solution**: Use theme shadow constants instead of custom shadows

### Issue: Layout jumps during animation
**Solution**: Wrap AnimatedCard in SizedBox with fixed height, or use `maintainSize: true` in Visibility

---

## 📚 Additional Resources

- [DESIGN_IMPROVEMENTS.md](DESIGN_IMPROVEMENTS.md) - Comprehensive design guide
- [lib/widgets/README.md](lib/widgets/README.md) - Widget quick reference
- [Wallet Screen](lib/screens/wallet/wallet_screen.dart) - Example of fully migrated screen

---

**Happy Migrating! 🎨✨**

Each screen you update makes the app more polished and delightful for users.
