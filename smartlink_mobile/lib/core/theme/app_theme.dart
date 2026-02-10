import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors from HTML design system
  static const Color primaryColor = Color(0xFF21c45d);
  static const Color primaryDark = Color(0xFF16a34a);
  static const Color primaryLight = Color(0xFF4ade80);
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF0B0F14);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF111827);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color outlineLight = Color(0xFFE5E7EB);
  static const Color outlineDark = Color(0xFF1F2937);

  // Soft gradient colors for depth and aesthetics
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF21c45d), Color(0xFF16a34a)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFFF9FAFB), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient darkSubtleGradient = LinearGradient(
    colors: [Color(0xFF0B0F14), Color(0xFF111827)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Animation constants for smooth transitions
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 400);
  static const Duration verySlowAnimation = Duration(milliseconds: 600);

  // Smooth curves for natural motion
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve springCurve = Curves.elasticOut;

  // Spacing system for consistent layout
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 20.0;
  static const double space2Xl = 24.0;
  static const double space3Xl = 32.0;

  // Border radius for soft corners
  static const double radiusXs = 8.0;
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // Soft shadows for depth
  static List<BoxShadow> softShadowLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> mediumShadowLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> largeShadowLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> softShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> mediumShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> largeShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundLight,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    ),
    
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor,
      surface: surfaceLight,
      error: Color(0xFFDC2626),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textMain,
      outline: outlineLight,
    ),

    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textMain, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textMain, letterSpacing: -0.5),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textMain, letterSpacing: -0.3),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textMain),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textMain),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textMain),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textMain),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMain),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textMain),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textMain, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textMain, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textMain),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textMain),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textSecondary),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: backgroundLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: textMain),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textMain,
      ),
      shadowColor: Colors.black.withValues(alpha: 0.02),
    ),

    cardTheme: CardThemeData(
      color: surfaceLight,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: primaryColor.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        animationDuration: normalAnimation,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        side: const BorderSide(color: outlineLight, width: 1.5),
        foregroundColor: textMain,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        animationDuration: normalAnimation,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        animationDuration: fastAnimation,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.w400),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF111827),
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      elevation: 8,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: outlineLight,
      thickness: 1,
      space: 1,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withValues(alpha: 0.1),
      selectedColor: primaryColor,
      deleteIconColor: primaryColor,
      labelStyle: const TextStyle(color: textMain, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      elevation: 0,
      pressElevation: 0,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundDark,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      },
    ),
    
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor,
      surface: surfaceDark,
      error: Color(0xFFEF4444),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      outline: outlineDark,
    ),

    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.5),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.3),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
        titleSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondaryDark, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: textSecondaryDark),
      ),
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: backgroundDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      shadowColor: Colors.black.withValues(alpha: 0.3),
    ),

    cardTheme: CardThemeData(
      color: surfaceDark,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: primaryColor.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        animationDuration: normalAnimation,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        side: const BorderSide(color: outlineDark, width: 1.5),
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        animationDuration: normalAnimation,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        animationDuration: fastAnimation,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0F172A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textSecondaryDark, fontWeight: FontWeight.w400),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF1F2937),
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
      elevation: 8,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
      ),
    ),

    dividerTheme: const DividerThemeData(
      color: outlineDark,
      thickness: 1,
      space: 1,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: primaryColor.withValues(alpha: 0.2),
      selectedColor: primaryColor,
      deleteIconColor: primaryColor,
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusSm)),
      elevation: 0,
      pressElevation: 0,
    ),
  );
}
