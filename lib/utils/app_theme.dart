import 'package:flutter/material.dart';

class AppTheme {
  // Minimal monochrome palette
  static const Color black = Color(0xFF0F0F0F);
  static const Color darkGrey = Color(0xFF1C1C1C);
  static const Color midGrey = Color(0xFF3A3A3A);
  static const Color lightGrey = Color(0xFFE5E5E5);
  static const Color softerGrey = Color(0xFFF5F5F5);
  static const Color white = Colors.white;

  static RoundedRectangleBorder _pillShape([double radius = 999]) =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: white,
    colorScheme: const ColorScheme.light(
      primary: black,
      onPrimary: white,
      secondary: midGrey,
      onSecondary: white,
      surface: white,
      onSurface: black,
      outline: lightGrey,
      background: white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: softerGrey,
      foregroundColor: black,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.6),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.1),
      bodyLarge: TextStyle(fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: black,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        shape: _pillShape(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: black, width: 1.2),
        foregroundColor: black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        shape: _pillShape(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: lightGrey, width: 1.1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: lightGrey, width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: black, width: 1.4),
      ),
      contentPadding:
          const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 16),
    ),
    cardTheme: const CardThemeData(
      color: white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: StadiumBorder(),
    ),
    dividerColor: lightGrey,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    colorScheme: const ColorScheme.dark(
      primary: white,
      onPrimary: black,
      secondary: midGrey,
      onSecondary: black,
      surface: darkGrey,
      onSurface: white,
      outline: midGrey,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      foregroundColor: white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.6),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.1),
      bodyLarge: TextStyle(fontWeight: FontWeight.w500),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: lightGrey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: white,
        foregroundColor: black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        shape: _pillShape(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: white, width: 1.2),
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        shape: _pillShape(),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: midGrey, width: 1.1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: midGrey, width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: white, width: 1.4),
      ),
      contentPadding:
          const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 16),
    ),
    cardTheme: const CardThemeData(
      color: darkGrey,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: StadiumBorder(),
    ),
    dividerColor: midGrey,
  );
}
