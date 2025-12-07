import 'package:flutter/material.dart';

/// Global theme controller to toggle light/dark mode across the app.
final ValueNotifier<ThemeMode> appThemeMode =
    ValueNotifier<ThemeMode>(ThemeMode.light);

/// App color palette
class WordMapColors {
  // LIGHT
  static const lightBackground = Color(0xFFF2F2F7);
  static const lightSurface = Colors.white;
  static const lightCard = Colors.white;

  // DARK
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkSurface = Color(0xFF1F1F1F);
  static const darkCard = Color(0xFF242424);

  // Accents
  static const primaryBlue = Color(0xFF4A90E2);
  static const accentOrange = Color(0xFFFF9500);

  static const dividerDark = Color(0xFF2E2E2E);
}
