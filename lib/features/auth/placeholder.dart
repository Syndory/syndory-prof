import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/env/app_env.dart';
import '../../data/supabase/supabase_client.dart';
import '../debug_health/debug_health_screen.dart';
import '../profile/profile_screen.dart';
import 'auth_routes.dart';
import 'dev_login_screen.dart';

const bool _devLoginScreen = bool.fromEnvironment('DEV_LOGIN_SCREEN');

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final bool hasConfig = AppEnv.hasSupabaseConfig;
    final bool isInitialized = SupabaseClientProvider.isInitialized;

    if (!hasConfig || !isInitialized) {
      return const DebugHealthScreen();
    }

    return StreamBuilder<AuthState>(
      stream: SupabaseClientProvider.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            snapshot.data?.session ??
            SupabaseClientProvider.client.auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        if (session != null) {
          return const ProfileScreen();
        }

        if (_devLoginScreen && !kReleaseMode) {
          return const DevLoginScreen();
        }

        return AuthRoutes.loginScreen(context);
      },
    );
  }
}

class AuthPlaceholderScreen extends StatelessWidget {
  const AuthPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Connexion'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'La connexion officielle sera intégrée ici.\n'
                'En attendant, cette page servira de point d\'entrée.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DebugHealthScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.medical_services_outlined, size: 16),
                label: const Text('Ouvrir Debug / Health'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
