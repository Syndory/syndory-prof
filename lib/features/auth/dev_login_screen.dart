import 'package:flutter/material.dart';

import '../../app/env/app_env.dart';
import '../../app/navigation/main_shell.dart';
import '../../data/supabase/supabase_client.dart';

const String _devLoginEmail = String.fromEnvironment('DEV_LOGIN_EMAIL');
const String _devLoginPassword = String.fromEnvironment('DEV_LOGIN_PASSWORD');

class DevLoginScreen extends StatefulWidget {
  const DevLoginScreen({super.key});

  @override
  State<DevLoginScreen> createState() => _DevLoginScreenState();
}

class _DevLoginScreenState extends State<DevLoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: _devLoginEmail);
    _passwordController = TextEditingController(text: _devLoginPassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!AppEnv.hasSupabaseConfig || !SupabaseClientProvider.isInitialized) {
      setState(() {
        _errorMessage =
            'Supabase non initialise. Verifiez SUPABASE_URL et SUPABASE_ANON_KEY.';
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email et mot de passe requis.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Correct method: signInWithPassword({email, password})
      final result = await SupabaseClientProvider.client.auth
          .signInWithPassword(email: email, password: password);

      if (!mounted) {
        return;
      }

      if (result.session == null) {
        setState(() {
          _errorMessage = 'Connexion echouee. Verifiez vos identifiants.';
          _isLoading = false;
        });
        return;
      }

      if (!mounted) {
        return;
      }

      // Redirect to MainShell instead of just ProfileScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Erreur: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Connexion (temporaire)'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Connexion test (a retirer avant push)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: Text(_isLoading ? 'Connexion...' : 'Se connecter'),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Color(0xFFEB5757)),
                ),
              ],
              const SizedBox(height: 12),
              const Text(
                'Astuce: vous pouvez pre-remplir via --dart-define=DEV_LOGIN_EMAIL=...'
                ' et --dart-define=DEV_LOGIN_PASSWORD=... (dev uniquement).',
                style: TextStyle(fontSize: 12, color: Color(0xFF828282)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
