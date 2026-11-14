/// lib/views/theme/app_theme.dart
/// Design System — Yharbid Unified Tokens
/// Mode: Operate — productivity tool, warm neutral, restrained green accent
/// NO BLUE TONES — brand requirement per PRODUCT.md

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ======== COLOR PALETTE ========
  // Background layers
  static const Color backgroundLight = Color(0xFFF5F5F5); // Warm light gray
  static const Color backgroundDark  = Color(0xFF424242);

  // Surfaces (cards, containers)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark  = Color(0xFF303030);
  static const Color surfaceGray  = Color(0xFFF0F0F0); // Secondary surface
  static const Color cardLight    = Color(0xFFFFFFFF);
  static const Color cardDark     = Color(0xFF424242);

  // Text
  static const Color textPrimary   = Color(0xFF1A1A1A); // Near-black, readable
  static const Color textSecondary = Color(0xFF757575); // Mid-gray
  static const Color textTertiary  = Color(0xFF9E9E9E); // Placeholder, captions
  static const Color textOnDark    = Color(0xFFFFFFFF); // White text on dark bg
  static const Color textDark      = Color(0xFFFFFFFF); // alias

  // Accent / action — NO BLUE
  static const Color accentGreen    = Color(0xFF4CAF50); // Primary action
  static const Color accentGreenDark= Color(0xFF2E7D32); // Selected / pressed
  static const Color accentOrange   = Color(0xFFFF9800); // Warnings
  static const Color accentRed      = Color(0xFFF44336); // Danger / delete
  static const Color accentGray     = Color(0xFF9E9E9E); // Secondary actions
  static const Color buttonDark     = Color(0xFF757575); // Dark pill buttons

  // Status semantic tokens
  static const Color statusSuccess  = Color(0xFF4CAF50); // = accentGreen
  static const Color statusWarning  = Color(0xFFFF9800); // = accentOrange
  static const Color statusError    = Color(0xFFF44336); // = accentRed
  static const Color statusNeutral  = Color(0xFF9E9E9E); // = accentGray
  static const Color statusInfo     = Color(0xFF4CAF50); // green, no blue

  // Dividers and borders
  static const Color dividerColor   = Color(0xFFE0E0E0);
  static const Color borderColor    = Color(0xFFE0E0E0);
  static const Color borderStrong   = Color(0xFFBDBDBD);

  // Navigation
  static const Color navBarBackground = Color(0xFF757575); // Bottom nav dark gray

  // ======== SPACING SCALE ========
  static const double space2  = 2.0;
  static const double space4  = 4.0;
  static const double space6  = 6.0;
  static const double space8  = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;
  static const double space80 = 80.0;
  // Additional tokens used in Settings / components
  static const double space10 = 10.0;
  static const double space14 = 14.0;
  static const double space52 = 52.0;

  // ======== BORDER RADIUS ========
  static const double radiusXS     = 6.0;
  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge  = 16.0;
  static const double radiusXL     = 20.0;
  static const double radiusPill   = 30.0;
  static const double radiusCircle = 999.0;

  // ======== ELEVATION / SHADOWS ========
  /// Card shadow — standard white surfaces
  static List<BoxShadow> get shadowCard => const [
    BoxShadow(
      color: Color(0x14000000), // ~8% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Elevated shadow — dialogs, FABs, hero cards
  static List<BoxShadow> get shadowElevated => const [
    BoxShadow(
      color: Color(0x28000000), // ~16% black - stronger
      blurRadius: 24,
      offset: Offset(0, 6),
    ),
  ];

  /// Subtle shadow — nav bar, sticky headers
  static List<BoxShadow> get shadowSubtle => const [
    BoxShadow(
      color: Color(0x0A000000), // ~4% black
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  // ======== CONTENT WIDTH ========
  /// Maximum content width on wide screens (web desktop)
  static const double contentMaxWidth = 900.0;

  // ======== TYPOGRAPHY SCALE ========
  static const TextStyle displayLarge = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    height: 1.1,
    letterSpacing: -0.02,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    height: 1.2,
    letterSpacing: -0.01,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    height: 1.25,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    fontFamily: 'NotoSansThai',
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondary,
    fontFamily: 'NotoSansThai',
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    fontFamily: 'NotoSansThai',
    letterSpacing: 0.2,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: textTertiary,
    fontFamily: 'NotoSansThai',
    height: 1.4,
  );

  // Additional typography variants for comprehensive coverage
  static const TextStyle body13 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    height: 1.5,
  );

  static const TextStyle body15 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    height: 1.5,
  );

  static const TextStyle label14 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    letterSpacing: 0.2,
  );

  static const TextStyle title18 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'NotoSansThai',
    height: 1.3,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: surfaceLight,
    fontFamily: 'NotoSansThai',
  );

  // ======== SHARED DECORATIONS ========
  /// Standard white card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceLight,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: shadowCard,
  );

  /// Surface with border (for inputs, outlined containers)
  static BoxDecoration get outlinedDecoration => BoxDecoration(
    color: surfaceLight,
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: borderColor, width: 1.0),
  );

  /// Status badge decoration helper
  static BoxDecoration statusBadgeDecoration(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(radiusPill),
    border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
  );

  // ======== LIGHT THEME ========
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,

    colorScheme: const ColorScheme.light(
      primary: accentGreen,
      onPrimary: Color(0xFFFFFFFF),
      secondary: accentGreenDark,
      onSecondary: Color(0xFFFFFFFF),
      surface: surfaceLight,
      onSurface: textPrimary,
      error: accentRed,
      onError: Color(0xFFFFFFFF),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        fontFamily: 'NotoSansThai',
      ),
    ),

    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'NotoSansThai',
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: BorderSide(color: borderStrong, width: 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'NotoSansThai',
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: 'NotoSansThai',
        ),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.bold,   color: textPrimary,   fontFamily: 'NotoSansThai'),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,   color: textPrimary,   fontFamily: 'NotoSansThai'),
      titleLarge:    TextStyle(fontSize: 20, fontWeight: FontWeight.bold,   color: textPrimary,   fontFamily: 'NotoSansThai'),
      titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w600,   color: textPrimary,   fontFamily: 'NotoSansThai'),
      titleSmall:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600,   color: textPrimary,   fontFamily: 'NotoSansThai'),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textPrimary,   fontFamily: 'NotoSansThai'),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textSecondary, fontFamily: 'NotoSansThai'),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: textSecondary, fontFamily: 'NotoSansThai'),
      labelMedium:   TextStyle(fontSize: 12, fontWeight: FontWeight.w600,   color: textSecondary, fontFamily: 'NotoSansThai'),
      labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: textTertiary,  fontFamily: 'NotoSansThai'),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderColor, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: borderColor, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: accentGreen, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textTertiary, fontFamily: 'NotoSansThai'),
    ),

    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1.0,
      space: 1.0,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: surfaceLight,
      selectedColor: accentGreen,
      side: const BorderSide(color: borderStrong, width: 1.0),
      labelStyle: const TextStyle(fontFamily: 'NotoSansThai', fontSize: 13),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusPill),
      ),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      contentTextStyle: const TextStyle(fontFamily: 'NotoSansThai', fontSize: 14),
    ),
  );

  // ======== DARK THEME ========
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,

    colorScheme: const ColorScheme.dark(
      primary: accentGreen,
      onPrimary: Color(0xFF000000),
      secondary: accentGreenDark,
      onSecondary: Color(0xFFFFFFFF),
      surface: surfaceDark,
      onSurface: textOnDark,
      error: accentRed,
      onError: Color(0xFFFFFFFF),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textOnDark),
      titleTextStyle: TextStyle(
        color: textOnDark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSansThai',
      ),
    ),

    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,
        foregroundColor: Color(0xFF000000),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansThai',
        ),
      ),
    ),

    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.bold,   color: textOnDark, fontFamily: 'NotoSansThai'),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,   color: textOnDark, fontFamily: 'NotoSansThai'),
      titleLarge:    TextStyle(fontSize: 20, fontWeight: FontWeight.bold,   color: textOnDark, fontFamily: 'NotoSansThai'),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: textOnDark, fontFamily: 'NotoSansThai'),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: textOnDark, fontFamily: 'NotoSansThai'),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: textOnDark, fontFamily: 'NotoSansThai'),
    ),
  );
}
