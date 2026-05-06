import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import '../features/auth/auth_routes.dart';
import '../features/auth/placeholder.dart';

import '../app/navigation/main_shell.dart';
import '../features/justifications/justification_list_page.dart';

// Flag DEV pour prévisualiser les justificatifs sans passer par l'auth
const bool _devJustifPreview = bool.fromEnvironment('DEV_JUSTIF_PREVIEW');

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      onGenerateRoute: AuthRoutes.onGenerateRoute,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      home: _devJustifPreview
          ? const JustificationListPage()
          : const AuthGate(),
    );
  }
}