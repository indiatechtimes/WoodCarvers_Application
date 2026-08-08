import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Colors lifted directly from design_guidelines.json so the Flutter app
// matches the original React site's earthy/organic palette.
class AppColors {
  static const background = Color(0xFFFAFAF7);
  static const foreground = Color(0xFF2C3525);
  static const primary = Color(0xFF4A5D3E); // deep olive green
  static const primaryForeground = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFE8E9E1);
  static const secondaryForeground = Color(0xFF2C3525);
  static const accent = Color(0xFFD2A679); // warm tan/wood
  static const accentForeground = Color(0xFFFFFFFF);
  static const muted = Color(0xFFF0F0EA);
  static const mutedForeground = Color(0xFF6B7262);
  static const border = Color(0xFFE2E4DC);
  static const card = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get light {
    final headingFont = GoogleFonts.playfairDisplayTextTheme();
    final bodyFont = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.primaryForeground,
        secondary: AppColors.accent,
        onSecondary: AppColors.accentForeground,
        surface: AppColors.background,
        onSurface: AppColors.foreground,
      ),
      textTheme: bodyFont.copyWith(
        displayLarge: headingFont.displayLarge?.copyWith(color: AppColors.foreground),
        displayMedium: headingFont.displayMedium?.copyWith(color: AppColors.foreground),
        headlineLarge: headingFont.headlineLarge?.copyWith(color: AppColors.foreground),
        headlineMedium: headingFont.headlineMedium?.copyWith(color: AppColors.foreground),
        headlineSmall: headingFont.headlineSmall?.copyWith(color: AppColors.foreground),
        titleLarge: headingFont.titleLarge?.copyWith(color: AppColors.foreground),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          textStyle: bodyFont.bodyMedium,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      dividerColor: AppColors.border,
      cardColor: AppColors.card,
    );
  }
}
