import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../app/navigation/main_shell.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/supabase/supabase_client.dart';
import '../../data/types/user_role.dart';
import 'auth_routes.dart';

/// Composant de garde d'authentification.
/// 
/// Surveille l'état de la session Supabase et gère la redirection
/// vers l'application principale ou l'écran de connexion en fonction
/// de l'authentification et du rôle de l'utilisateur.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseClientProvider.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ??
            SupabaseClientProvider.client.auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        if (session != null) {
          return FutureBuilder(
            future: UserRepository.getCurrentProfile(),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const _AuthLoadingScreen();
              }

              if (profileSnapshot.hasError) {
                return _ErrorScreen(
                  message: 'Erreur lors du chargement de votre profil.',
                  onAction: () => SupabaseClientProvider.client.auth.signOut(),
                  actionLabel: 'Déconnexion',
                );
              }

              final profile = profileSnapshot.data;
              if (profile == null) {
                return _ErrorScreen(
                  message: 'Profil introuvable pour ${session.user.email}.',
                  onAction: () => SupabaseClientProvider.client.auth.signOut(),
                  actionLabel: 'Déconnexion',
                );
              }

              // Vérification du rôle Professor ou Admin
              if (profile.role != UserRole.professor && profile.role != UserRole.admin) {
                return _ErrorScreen(
                  message: 'Accès refusé. Cette application est réservée aux professeurs.',
                  onAction: () => SupabaseClientProvider.client.auth.signOut(),
                  actionLabel: 'Déconnexion',
                );
              }

              if (!profile.isActive) {
                return _ErrorScreen(
                  message: 'Votre compte a été désactivé.',
                  onAction: () => SupabaseClientProvider.client.auth.signOut(),
                  actionLabel: 'Déconnexion',
                );
              }

              return const MainShell();
            },
          );
        }

        return AuthRoutes.loginScreen(context);
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _ErrorScreen({
    required this.message,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel ?? 'Action'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
