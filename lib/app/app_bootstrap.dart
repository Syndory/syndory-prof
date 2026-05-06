import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/auth/auth_routes.dart';
import '../features/auth/placeholder.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      onGenerateRoute: AuthRoutes.onGenerateRoute,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      home: const AuthGate(),
    );
  }
}
