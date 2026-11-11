import 'package:flutter/material.dart';

class AppColors {
  static const dark = Color(0xFF33333B);
  static const grey = Color(0xFF9CA1AA);
  static const surface = Color(0xFFF5F5F7);
  static const green = Color(0xFF4B7F6C);
  static const heroBg = Color(0xFFFFF9F5);
  static const red = Color(0xFFEF4B4B);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.dark),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: AppColors.dark,
          elevation: 0,
          centerTitle: true,
        ),
      );
}
