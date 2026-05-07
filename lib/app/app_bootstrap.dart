import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

import 'env/app_env.dart';
import 'errors/missing_supabase_config_screen.dart';
import '../features/auth/auth_routes.dart';
import '../features/auth/auth_gate.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      onGenerateRoute: AuthRoutes.onGenerateRoute,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      home: AppEnv.hasSupabaseConfig
          ? const AuthGate()
          : const MissingSupabaseConfigScreen(),
    );
  }
}