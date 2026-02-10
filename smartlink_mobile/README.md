# SmartLink Mobile - Flutter App

A beautiful, trust-first neighborhood marketplace built with Flutter.

## 🎨 Recent UI Improvements

The app now features a completely redesigned soft and smooth UI with:
- **Soft multi-layered shadows** for realistic depth
- **Smooth entrance animations** with staggered timing
- **Interactive feedback** on all touchable elements
- **Gradient backgrounds** for visual interest
- **Consistent spacing system** (7 levels from 4-32px)
- **Polished animations** running at 60fps

### 📚 Documentation

- **[DESIGN_IMPROVEMENTS.md](DESIGN_IMPROVEMENTS.md)** - Comprehensive guide to all design improvements
- **[SCREEN_MIGRATION_GUIDE.md](SCREEN_MIGRATION_GUIDE.md)** - Step-by-step guide to apply improvements to screens
- **[BEFORE_AFTER.md](BEFORE_AFTER.md)** - Visual comparison of improvements
- **[lib/widgets/README.md](lib/widgets/README.md)** - Quick reference for reusable widgets

### ✅ Already Polished Screens

- ✓ Splash Screen - Glassmorphism with floating blur circles
- ✓ Onboarding - Smooth page transitions
- ✓ Auth & Register - Gradient backgrounds and smooth forms
- ✓ Wallet Screen - Fully migrated with all improvements

### 🎯 Key Components

#### Smooth Widgets
- `AnimatedCard` - Interactive cards with press animation
- `SmoothButton` - 4 button styles with gradients
- `FadeInSlide` - Entrance animations
- `GradientBackground` - Subtle gradient backgrounds
- `SectionDivider` - Beautiful dividers
- `SmoothBadge` - Polished badges

#### Design System
- **AppTheme** - Centralized theme with design tokens
- **Shadows** - 6 predefined shadow levels
- **Spacing** - 7-level spacing system
- **Radius** - 6 border radius sizes
- **Animations** - Consistent durations and curves

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- iOS development tools (for iOS)

### Installation

```bash
# Clone the repository
git clone <repository-url>

# Navigate to the smartlink_mobile directory
cd smartlink_mobile

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Building

```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📦 Dependencies

Key packages used:
- `provider` (^6.1.1) - State management
- `dio` (^5.4.0) - HTTP client
- `google_fonts` (^6.1.0) - Typography
- `cached_network_image` (^3.3.1) - Image caching
- `shimmer` (^3.0.0) - Loading states
- `google_maps_flutter` (^2.5.3) - Maps integration
- `socket_io_client` (^3.1.2) - Real-time communication

## 🏗️ Project Structure

```
smartlink_mobile/
├── lib/
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Centralized theme
│   │   ├── utils/
│   │   │   ├── animations.dart         # Animation utilities
│   │   │   └── formatting.dart         # String formatting
│   │   └── router/
│   │       └── app_router.dart         # Navigation
│   ├── widgets/
│   │   └── common/
│   │       ├── animated_card.dart      # Interactive cards
│   │       ├── smooth_button.dart      # Polished buttons
│   │       ├── fade_in_slide.dart      # Entrance animations
│   │       ├── gradient_background.dart # Gradient backgrounds
│   │       ├── section_divider.dart    # Section dividers
│   │       ├── smooth_badge.dart       # Badges
│   │       ├── shop_card.dart          # Shop cards
│   │       ├── wallet_card.dart        # Wallet card
│   │       ├── shimmer_box.dart        # Loading states
│   │       └── bottom_nav_bar.dart     # Navigation bar
│   ├── screens/
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── auth/
│   │   ├── home/
│   │   ├── wallet/                     # ✅ Fully updated
│   │   ├── orders/
│   │   ├── profile/
│   │   └── ...
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── wallet_provider.dart
│   │   └── ...
│   └── main.dart
├── assets/
│   ├── images/
│   └── mock_data/
├── DESIGN_IMPROVEMENTS.md              # Design guide
├── SCREEN_MIGRATION_GUIDE.md           # Migration guide
├── BEFORE_AFTER.md                     # Visual comparison
└── README.md                            # This file
```

## 🎨 Design System

### Colors
- **Primary**: `#21c45d` (Green)
- **Primary Dark**: `#16a34a`
- **Background Light**: `#F9FAFB`
- **Background Dark**: `#0B0F14`
- **Text Main**: `#0F172A`
- **Text Secondary**: `#6B7280`

### Typography
- **Font Family**: Inter (via Google Fonts)
- **Sizes**: 10-32px (8 levels)
- **Weights**: 400, 500, 600, 700, 800, 900

### Spacing
- **XS**: 4px
- **SM**: 8px
- **MD**: 12px
- **LG**: 16px
- **XL**: 20px
- **2XL**: 24px
- **3XL**: 32px

### Border Radius
- **XS**: 8px
- **SM**: 12px
- **MD**: 16px
- **LG**: 20px
- **XL**: 24px
- **Full**: 999px

## 🔧 Configuration

### Environment Variables

The app connects to the SmartLink API backend. Configure the API endpoint in:
```dart
// lib/core/api/api_config.dart
static const String baseUrl = 'YOUR_API_URL';
```

### Mock Data

For development, mock data is available in:
- `assets/mock_data/products.json`
- `assets/mock_data/users.json`

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📱 Features

- **Trust-First Marketplace** - Verified sellers with trust signals
- **Protected Payments** - Escrow holds until delivery confirmation
- **Hyper-Local Delivery** - Powered by nearby riders
- **Real-Time Tracking** - Track orders in real-time
- **Wallet System** - Secure in-app wallet with transactions
- **Multi-Role Support** - Customer, Merchant, and Rider roles
- **Dark Mode** - Full dark theme support

## 🤝 Contributing

When adding new screens or components:

1. Follow the design patterns in existing screens
2. Use the design system (AppTheme constants)
3. Add smooth animations where appropriate
4. Test on both light and dark themes
5. Refer to [SCREEN_MIGRATION_GUIDE.md](SCREEN_MIGRATION_GUIDE.md)

## 📄 License

This project is proprietary and confidential.

## 📞 Support

For questions or issues, contact the SmartLink development team.

---

**Built with ❤️ using Flutter**
