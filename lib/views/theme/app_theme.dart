/// lib/views/theme/app_theme.dart
/// Design System Engine — สกัดสีและสไตล์จาก Mockups
/// รองรับ Light/Dark Mode พร้อม Typography ที่ใช้ Noto Sans Thai

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ======== สี Palette จาก Mockup ========
  // Background: Blue-Gray Steel (#B0BEC5)
  static const Color backgroundLight = Color(0xFFB0BEC5);
  static const Color backgroundDark = Color(0xFF607D8B);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF263238);
  static const Color cardLight = Color(0xFFCFD8DC);
  static const Color cardDark = Color(0xFF455A64);
  static const Color textPrimary = Color(0xFF000000);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color accentPrimary = Color(0xFF1976D2);
  static const Color accentSecondary = Color(0xFF4CAF50);
  static const Color dividerColor = Color(0xFFE0E0E0);

  // ======== Border Radius คงที่ตาม Mockup ========
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusPill = 30.0;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'NotoSansThai',
      ),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: cardLight,
        foregroundColor: textPrimary,
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
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceLight,
      elevation: 8,
      selectedItemColor: accentPrimary,
      unselectedItemColor: textSecondary,
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
