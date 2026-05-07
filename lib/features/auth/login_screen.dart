import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/theme/app_theme.dart';
import '../../data/supabase/supabase_client.dart';
import '../../app/navigation/main_shell.dart';
import 'auth_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez saisir votre email et votre mot de passe.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('[AUTH] Attempting sign in for: $email');
      
      // Ensure we use the correct method: signInWithPassword({email, password})
      final response = await SupabaseClientProvider.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      debugPrint('[AUTH] Sign in successful');

      if (!mounted) return;

      // Manual redirect to MainShell as requested. 
      // AuthGate will also react, but this ensures immediate navigation feedback.
      if (response.session != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } on AuthException catch (e) {
      debugPrint('[AUTH] AuthException: ${e.message} (Status: ${e.statusCode})');
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      debugPrint('[AUTH] Unexpected error: $e');
      setState(() {
        _errorMessage = 'Une erreur inattendue est survenue.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showForgotPasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ForgotPasswordSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Logo & Brand
              const _HeroSection(),
              const SizedBox(height: 40),
              // Login Card
              _LoginCard(
                emailController: _emailController,
                passwordController: _passwordController,
                isLoading: _isLoading,
                obscurePassword: _obscurePassword,
                errorMessage: _errorMessage,
                onTogglePassword: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
                onLogin: _signIn,
                onForgotPassword: _showForgotPasswordSheet,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/image.png',
          height: 140,
        ),
        const SizedBox(height: 16),
        Text(
          'ESPACE PROFESSEUR',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.gray2,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final String? errorMessage;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  const _LoginCard({
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.errorMessage,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onForgotPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.gray5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connexion',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondary,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Saisissez vos identifiants administrés.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.gray2,
                ),
          ),
          const SizedBox(height: 24),
          // Email Field
          Text('Email', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'prenom.nom@ecole.tld',
              suffixIcon: Icon(Icons.alternate_email, color: AppTheme.gray4),
            ),
          ),
          const SizedBox(height: 16),
          // Password Field
          Text('Mot de passe', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: '••••••••',
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.gray4,
                ),
                onPressed: onTogglePassword,
              ),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorDim,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style:
                          const TextStyle(color: AppTheme.error, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : onLogin,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Se connecter'),
            ),
          ),
          const SizedBox(height: 4),
          // Forgot Password
          Center(
            child: TextButton(
              onPressed: onForgotPassword,
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  color: Color(0xFF2F80ED),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  Future<void> _resetPassword() async {
    setState(() => _isLoading = true);
    try {
      await SupabaseClientProvider.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
      );
      setState(() => _isSuccess = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi du lien.')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 44),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.gray5,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          if (_isSuccess) ...[
            const Icon(Icons.check_circle, color: AppTheme.success, size: 72),
            const SizedBox(height: 20),
            const Text(
              'Lien envoyé !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Consultez votre boîte mail pour réinitialiser votre mot de passe.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.gray2, fontSize: 14.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
                child: const Text('Compris'),
              ),
            ),
          ] else ...[
            const Text(
              'Mot de passe oublié',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Entrez votre email pour recevoir un lien de réinitialisation.',
              style: TextStyle(color: AppTheme.gray2, fontSize: 14.5),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Email', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'prenom.nom@ecole.tld',
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Envoyer le lien'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler', style: TextStyle(color: AppTheme.gray2)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
