import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.navyBlue, size: 24);
        }
        return const IconThemeData(color: Colors.grey, size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.navyBlue);
        }
        return const TextStyle(fontSize: 11, color: Colors.grey);
      }),
    ),
  );
}
