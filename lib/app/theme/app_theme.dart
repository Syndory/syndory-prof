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

  static const Color primary = AppColors.primary;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color primaryDim = AppColors.primaryDim;
  static const Color secondary = AppColors.secondary;
  static const Color secondaryDim = AppColors.secondaryDim;
  static const Color surfaceDark = AppColors.surfaceDark;
  static const Color success = AppColors.success;
  static const Color error = AppColors.error;
  static const Color errorDim = AppColors.errorDim;
  static const Color gray2 = AppColors.gray2;
  static const Color gray4 = AppColors.gray4;
  static const Color gray5 = AppColors.gray5;
}
