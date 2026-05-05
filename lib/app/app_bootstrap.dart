import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/auth/auth_routes.dart';
import '../features/auth/placeholder.dart';
import '../features/profile/profile_screen.dart';

// Permet d'activer un aperçu rapide de l'écran Profil en dev :
// flutter run --dart-define=DEV_PROFILE_PREVIEW=true
const bool _devProfilePreview = bool.fromEnvironment('DEV_PROFILE_PREVIEW');

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      onGenerateRoute: AuthRoutes.onGenerateRoute,
      home: _devProfilePreview ? const ProfileScreen() : const AuthGate(),
    );
  }
}
