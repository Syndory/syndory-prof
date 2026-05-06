import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../app/navigation/main_shell.dart';
import '../features/auth/auth_routes.dart';
import '../features/justifications/justification_routes.dart';
import '../features/auth/placeholder.dart';
import '../features/profile/profile_screen.dart';
import '../features/justifications/justification_list_page.dart';

const bool _devJustifPreview = bool.fromEnvironment('DEV_JUSTIF_PREVIEW');
const bool _devProfilePreview = bool.fromEnvironment('DEV_PROFILE_PREVIEW');

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      onGenerateRoute: (settings) {
        return AuthRoutes.onGenerateRoute(settings) ??
            JustificationRoutes.onGenerateRoute(settings);
      },
      home: _devJustifPreview
          ? const JustificationListPage()
          : (_devProfilePreview
              ? const ProfileScreen()
              : const MainShell()),
    );
  }
}