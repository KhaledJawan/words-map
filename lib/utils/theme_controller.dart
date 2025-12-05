import 'package:flutter/material.dart';

/// Global theme mode controller used across the app for simple toggling.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.light);
