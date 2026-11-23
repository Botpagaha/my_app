import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents from Google Stitch Design System
  static const Color primary = Color(0xFF9E3B4D); // Deep Wine Rose
  static const Color primaryContainer = Color(0xFFFFD9DC);
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryContainer = Color(0xFF3F0010);

  static const Color secondary = Color(0xFFE27387); // Soft Rose
  static const Color secondaryContainer = Color(0xFFFF8B9F);
  static const Color onSecondary = Colors.white;
  static const Color onSecondaryContainer = Color(0xFF3F0013);

  static const Color tertiary = Color(0xFF6C3537); // Warm Berry Brown
  static const Color tertiaryContainer = Color(0xFFF4A8A8);
  static const Color onTertiary = Colors.white;

  // Background & Surfaces
  static const Color background = Color(0xFFFFF8F7);
  static const Color surface = Color(0xFFFFF8F7);
  static const Color surfaceContainer = Color(0xFFF9EAEB);
  static const Color surfaceContainerHigh = Color(0xFFF4E5E6);
  static const Color surfaceContainerHighest = Color(0xFFEEDFE0);
  static const Color surfaceContainerLow = Color(0xFFFFF1F2);
  static const Color surfaceContainerLowest = Colors.white;

  // Typography & Outlines
  static const Color onSurface = Color(0xFF211A1B); // Deep Charcoal
  static const Color onSurfaceVariant = Color(0xFF534345);
  static const Color outline = Color(0xFF887173);
  static const Color outlineVariant = Color(0xFFDBC0C2);

  // States
  static const Color success = Color(0xFF2E7D32);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9E3B4D),
      Color(0xFFB54C60),
      Color(0xFFE27387),
    ],
  );

  static const LinearGradient cardSoftGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF8F7),
      Color(0xFFF9EAEB),
    ],
  );
}
