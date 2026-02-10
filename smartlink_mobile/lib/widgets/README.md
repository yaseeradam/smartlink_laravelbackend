# SmartLink Widgets - Quick Reference

## 🎨 Common Widgets

### Interactive Cards

```dart
// Animated card with smooth press effect
AnimatedCard(
  onTap: () {},
  child: YourContent(),
)

// Shop card
ShopCard(
  shop: shopData,
  onTap: () => navigateToShop(),
)

// Wallet card
WalletCard(
  balance: 25000.50,
  onTap: () => navigateToWallet(),
)
```

### Buttons

```dart
// Primary button
SmoothButton(
  text: 'Get Started',
  icon: Icons.arrow_forward_rounded,
  onPressed: () {},
  style: SmoothButtonStyle.primary,
)

// Secondary button
SmoothButton(
  text: 'Cancel',
  onPressed: () {},
  style: SmoothButtonStyle.secondary,
)

// Outline button
SmoothButton(
  text: 'Learn More',
  onPressed: () {},
  style: SmoothButtonStyle.outline,
)

// Ghost button
SmoothButton(
  text: 'Skip',
  onPressed: () {},
  style: SmoothButtonStyle.ghost,
)
```

### Animations

```dart
// Fade in with slide
FadeInSlide(
  delay: Duration(milliseconds: 100),
  child: YourWidget(),
)

// Staggered list
StaggeredList(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(),
)

// Smooth tap feedback
YourWidget().withSmoothTap(onTap: () {})
```

### Backgrounds & Decorations

```dart
// Gradient background
GradientBackground(
  child: ScreenContent(),
)

// Decorative circle
DecorativeCircle(
  size: 300,
  alignment: Alignment.topRight,
  opacity: 0.1,
)

// Section divider
SectionDivider(title: 'Popular Items')
```

### Badges & Labels

```dart
// Smooth badge
SmoothBadge(
  text: 'Trusted',
  icon: Icons.verified,
  color: AppTheme.primaryColor,
)

// Outlined badge
SmoothBadge(
  text: 'New',
  outlined: true,
)
```

### Loading States

```dart
// Shimmer box
ShimmerBox(
  width: 100,
  height: 20,
)

// Shimmer card
ShimmerCard(
  height: 200,
  margin: EdgeInsets.all(16),
)

// Shimmer circle
ShimmerCircle(diameter: 48)
```

## 🎯 Design Tokens

### Spacing
```dart
AppTheme.spaceXs   // 4px
AppTheme.spaceSm   // 8px
AppTheme.spaceMd   // 12px
AppTheme.spaceLg   // 16px
AppTheme.spaceXl   // 20px
AppTheme.space2Xl  // 24px
AppTheme.space3Xl  // 32px
```

### Border Radius
```dart
AppTheme.radiusXs   // 8px
AppTheme.radiusSm   // 12px
AppTheme.radiusMd   // 16px
AppTheme.radiusLg   // 20px
AppTheme.radiusXl   // 24px
AppTheme.radiusFull // 999px
```

### Shadows
```dart
AppTheme.softShadowLight    // Light theme, subtle
AppTheme.mediumShadowLight  // Light theme, medium
AppTheme.largeShadowLight   // Light theme, prominent
AppTheme.softShadowDark     // Dark theme, subtle
AppTheme.mediumShadowDark   // Dark theme, medium
AppTheme.largeShadowDark    // Dark theme, prominent
```

### Animations
```dart
AppTheme.fastAnimation       // 200ms
AppTheme.normalAnimation     // 300ms
AppTheme.slowAnimation       // 400ms
AppTheme.verySlowAnimation   // 600ms
```

### Curves
```dart
AppTheme.smoothCurve   // easeInOutCubic
AppTheme.bounceCurve   // easeOutBack
AppTheme.springCurve   // elasticOut
```

## 📚 Import Paths

```dart
// Theme
import 'package:smartlink_mobile/core/theme/app_theme.dart';

// Animations
import 'package:smartlink_mobile/core/utils/animations.dart';

// Widgets
import 'package:smartlink_mobile/widgets/common/animated_card.dart';
import 'package:smartlink_mobile/widgets/common/smooth_button.dart';
import 'package:smartlink_mobile/widgets/common/fade_in_slide.dart';
import 'package:smartlink_mobile/widgets/common/gradient_background.dart';
import 'package:smartlink_mobile/widgets/common/section_divider.dart';
import 'package:smartlink_mobile/widgets/common/smooth_badge.dart';
import 'package:smartlink_mobile/widgets/common/shimmer_box.dart';
import 'package:smartlink_mobile/widgets/common/shop_card.dart';
import 'package:smartlink_mobile/widgets/common/wallet_card.dart';
```

## 💡 Common Patterns

### Screen with gradient background
```dart
Scaffold(
  body: GradientBackground(
    child: SafeArea(
      child: YourContent(),
    ),
  ),
)
```

### List with staggered animation
```dart
StaggeredList(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return AnimatedCard(
      margin: EdgeInsets.all(AppTheme.spaceMd),
      onTap: () => handleTap(items[index]),
      child: ItemContent(items[index]),
    );
  },
)
```

### Card with shadow
```dart
Container(
  decoration: BoxDecoration(
    color: isDark ? AppTheme.surfaceDark : Colors.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
    boxShadow: isDark 
      ? AppTheme.mediumShadowDark 
      : AppTheme.mediumShadowLight,
  ),
  child: YourContent(),
)
```

### Button group
```dart
Row(
  children: [
    Expanded(
      child: SmoothButton(
        text: 'Cancel',
        onPressed: () {},
        style: SmoothButtonStyle.secondary,
      ),
    ),
    SizedBox(width: AppTheme.spaceMd),
    Expanded(
      child: SmoothButton(
        text: 'Confirm',
        onPressed: () {},
        style: SmoothButtonStyle.primary,
      ),
    ),
  ],
)
```

---

For detailed documentation, see [DESIGN_IMPROVEMENTS.md](../DESIGN_IMPROVEMENTS.md)
