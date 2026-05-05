import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import '../shared/widgets/main_scaffold.dart';
import '../data/supabase/supabase_client.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      home: const MainScaffold(),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    if (!SupabaseClientProvider.isInitialized) {
      return const LoginScreen();
    }

    return StreamBuilder<AuthState>(
      stream: SupabaseClientProvider.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session
            ?? SupabaseClientProvider.client.auth.currentSession;

        if (session != null) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
