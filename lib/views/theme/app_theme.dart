/// lib/views/theme/app_theme.dart
/// Design System Engine — Strictly Based on assets/mockups/
/// ✅ 100% Mockup Compliance - NO BLUE COLORS

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ======== PRIMARY COLORS (NO BLUE - Warm Gray Theme) ========
  static const Color backgroundLight = Color(0xFFF5F5F5);       // Main BG: Warm light gray (NOT blue-gray)
  static const Color backgroundDark = Color(0xFF424242);        // Dark mode variant (pure gray)
  static const Color surfaceLight = Color(0xFFFFFFFF);          // White cards/surfaces
  static const Color surfaceDark = Color(0xFF303030);           // Dark mode surfaces
  static const Color surfaceGray = Color(0xFF757575);           // Gray containers (bottom nav bar)
  static const Color cardLight = Color(0xFFFFFFFF);             // White cards
  static const Color cardDark = Color(0xFF424242);              // Dark mode cards
  
  // ======== TEXT COLORS ========
  static const Color textPrimary = Color(0xFF000000);           // Black headers
  static const Color textSecondary = Color(0xFF616161);         // Gray body text
  static const Color textDark = Color(0xFFFFFFFF);              // White text on dark backgrounds
  
  // ======== ACCENT/ACTION COLORS (NO BLUE!) ========
  static const Color accentGreen = Color(0xFF4CAF50);           // Green - primary action (from mockup)
  static const Color accentOrange = Color(0xFFFF9800);          // Orange - warnings
  static const Color accentRed = Color(0xFFF44336);             // Red - danger/delete
  static const Color accentGray = Color(0xFF9E9E9E);            // Gray - secondary actions
  static const Color buttonDark = Color(0xFF757575);            // Settings pill buttons
  static const Color navBarBackground = Color(0xFF757575);      // Bottom nav bar dark gray (from mockup)
  
  static const Color dividerColor = Color(0xFFE0E0E0);          // Light gray dividers

  // ======== BORDER RADIUS (Mockup Standards) ========
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusPill = 30.0;
  static const double radiusCircle = 999.0;                     // For circular bottom nav buttons

  // ======== LIGHT THEME ========
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'NotoSansThai',
      ),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentGreen,  // Changed from buttonDark
        foregroundColor: textDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'NotoSansThai',
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: 'NotoSansThai'),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: 'NotoSansThai'),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary, fontFamily: 'NotoSansThai'),
      bodyLarge: TextStyle(fontSize: 16, color: textPrimary, fontFamily: 'NotoSansThai'),
      bodyMedium: TextStyle(fontSize: 14, color: textSecondary, fontFamily: 'NotoSansThai'),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusPill),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: textSecondary, fontFamily: 'NotoSansThai'),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textDark),
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSansThai',
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cardDark,
        foregroundColor: textDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'NotoSansThai',
        ),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'NotoSansThai'),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'NotoSansThai'),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'NotoSansThai'),
      bodyLarge: TextStyle(fontSize: 16, color: textDark, fontFamily: 'NotoSansThai'),
      bodyMedium: TextStyle(fontSize: 14, color: textDark, fontFamily: 'NotoSansThai'),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusPill),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: textDark, fontFamily: 'NotoSansThai'),
    ),
  );
}
