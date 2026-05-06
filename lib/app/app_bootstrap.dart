import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/auth/auth_routes.dart';
import '../features/auth/placeholder.dart';
import '../features/profile/profile_screen.dart';
import '../features/resources/screens/resources_screen.dart';

const bool _devProfilePreview = bool.fromEnvironment('DEV_PROFILE_PREVIEW');
const bool _devResourcesPreview =
    bool.fromEnvironment('DEV_RESOURCES_PREVIEW');
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    final Widget home;
    if (_devResourcesPreview) {
      home = const ResourcesScreen();
    } else if (_devProfilePreview) {
      home = const ProfileScreen();
    } else {
      home = const AuthGate();
    }

    return MaterialApp(
      title: 'Syndory Prof',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      onGenerateRoute: AuthRoutes.onGenerateRoute,
      home: home,
    );
  }
}