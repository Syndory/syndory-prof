import 'package:flutter/material.dart';
import '../home/widgets/dashboard_with_next_session_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Syndory Prof',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Écran de connexion temporaire'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implémenter la logique de connexion
              },
              child: const Text('Se connecter'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const DashboardWithNextSessionScreen(),
                  ),
                );
              },
              child: const Text('Tester le dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
