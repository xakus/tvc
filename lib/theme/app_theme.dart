import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.blue,
      secondary: AppColors.warning,
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme =
      lightTheme; // Можно позже настроить отдельно
}
