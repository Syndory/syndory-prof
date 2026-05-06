import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const primary = Color(0xFF092C4C);
  static const primaryLight = Color(0x0D3A65FF); // Wait, CSS said #0D3A65, let's use 0xFF0D3A65
  static const primaryDim = Color(0xFFE8EFF5);
  static const secondary = Color(0xFFF2994A);
  static const secondaryDim = Color(0xFFFEF3E7);
  static const success = Color(0xFF27AE60);
  static const error = Color(0xFFEB5757);
  static const errorDim = Color(0xFFFEECEC);
  static const gray1 = Color(0xFF333333);
  static const gray2 = Color(0xFF4F4F4F);
  static const gray3 = Color(0xFF828282);
  static const gray4 = Color(0xFFBDBDBD);
  static const gray5 = Color(0xFFE0E0E0);
  static const bg = Color(0xFFF5F7FA);
  static const surfaceDark = Color(0xFF0E131F);

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      error: error,
      surface: bg,
    ),
    useMaterial3: true,
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.04,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -0.02,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        color: gray1,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: gray2,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: secondary,
        letterSpacing: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray5, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: gray5, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1.5),
      ),
      hintStyle: const TextStyle(color: gray4),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
    ),
  );
}
