import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = Typography.material2021().black;

    final textTheme = TextTheme(
      // Playfair Display for Romantic Headlines & Counters
      displayLarge: GoogleFonts.playfairDisplay(
        textStyle: baseTextTheme.displayLarge,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        textStyle: baseTextTheme.displayMedium,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        textStyle: baseTextTheme.displaySmall,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      headlineLarge: GoogleFonts.playfairDisplay(
        textStyle: baseTextTheme.headlineLarge,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      headlineMedium: GoogleFonts.playfairDisplay(
        textStyle: baseTextTheme.headlineMedium,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      headlineSmall: GoogleFonts.playfairDisplay(
        textStyle: baseTextTheme.headlineSmall,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      
      // Plus Jakarta Sans for Body, Subtitles & Labels
      titleLarge: GoogleFonts.plusJakartaSans(
        textStyle: baseTextTheme.titleLarge,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        textStyle: baseTextTheme.titleMedium,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        textStyle: baseTextTheme.titleSmall,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        textStyle: baseTextTheme.bodyLarge,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.onSurface,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        textStyle: baseTextTheme.bodyMedium,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.onSurfaceVariant,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        textStyle: baseTextTheme.bodySmall,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        textStyle: baseTextTheme.labelLarge,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        textStyle: baseTextTheme.labelMedium,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        textStyle: baseTextTheme.labelSmall,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.surfaceContainerHigh, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
    );
  }
}
