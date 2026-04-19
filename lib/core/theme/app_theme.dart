import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0F766E);
  static const Color secondary = Color(0xFF0EA5A4);
  static const Color accent = Color(0xFFEA580C);
  static const Color ink = Color(0xFF102A43);
  static const Color mutedText = Color(0xFF5C6B7A);
  static const Color softBackground = Color(0xFFF4FAF9);
  static const Color success = Color(0xFF15803D);
  static const Color danger = Color(0xFFDC2626);
  static const Color border = Color(0xFFE4ECEC);

  static ThemeData get lightTheme {
    final colorScheme = const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      surface: Colors.white,
      onSurface: ink,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      error: danger,
      outline: border,
    );

    final baseTextTheme = ThemeData.light().textTheme.apply(
      fontFamily: 'Cairo',
    );

    return ThemeData(
      fontFamily: 'Cairo',
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: ink,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: ink,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: ink,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          color: ink,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: ink,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: mutedText,
          height: 1.4,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: ink,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
          side: BorderSide(color: border),
        ),
      ),
      dividerColor: border,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: softBackground,
        hintStyle: TextStyle(color: mutedText.withValues(alpha: 0.75)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primary, width: 1.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: softBackground,
        selectedColor: primary.withValues(alpha: 0.12),
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(color: ink, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 78,
        indicatorColor: primary.withValues(alpha: 0.12),
        backgroundColor: Colors.white,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.white,
        useIndicator: true,
        indicatorColor: primary.withValues(alpha: 0.12),
        selectedIconTheme: const IconThemeData(color: primary),
        selectedLabelTextStyle: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w700,
        ),
        unselectedIconTheme: const IconThemeData(color: mutedText),
      ),
    );
  }
}
