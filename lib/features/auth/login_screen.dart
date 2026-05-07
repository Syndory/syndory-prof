import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/theme/app_theme.dart';
import '../../data/supabase/supabase_client.dart';
import '../../app/navigation/main_shell.dart';

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
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.surfaceDark,
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  Color(0xFF1A2A40),
                  AppTheme.surfaceDark,
                ],
              ),
            ),
          ),
          // Decorative Blobs (simplified)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryDim.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.secondaryDim.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
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
        ],
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
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.5),
                    blurRadius: 28,
                  ),
                ],
              ),
            ),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryLight, AppTheme.primary],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _LogoPainter(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Syndory',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'ESPACE PROFESSEUR',
          style: Theme.of(context).textTheme.labelSmall,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connexion',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Saisissez vos identifiants administrés.',
                style: Theme.of(context).textTheme.bodyMedium,
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
                      obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
                    border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: AppTheme.error, fontSize: 14),
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
        ),
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

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    // M7 14.5C8.7 16.8 11 18 13.5 18C17.1 18 20 15.1 20 11.5C20 7.9 17.1 5 13.5 5C11 5 8.7 6.2 7 8.5
    // Normalize to 24x24 viewbox and scale to size
    final scaleX = size.width / 24;
    final scaleY = size.height / 24;

    path1.moveTo(7 * scaleX, 14.5 * scaleY);
    path1.cubicTo(
      8.7 * scaleX, 16.8 * scaleY,
      11 * scaleX, 18 * scaleY,
      13.5 * scaleX, 18 * scaleY,
    );
    path1.cubicTo(
      17.1 * scaleX, 18 * scaleY,
      20 * scaleX, 15.1 * scaleY,
      20 * scaleX, 11.5 * scaleY,
    );
    path1.cubicTo(
      20 * scaleX, 7.9 * scaleY,
      17.1 * scaleX, 5 * scaleY,
      13.5 * scaleX, 5 * scaleY,
    );
    path1.cubicTo(
      11 * scaleX, 5 * scaleY,
      8.7 * scaleX, 6.2 * scaleY,
      7 * scaleX, 8.5 * scaleY,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    // M4 12H12
    path2.moveTo(4 * scaleX, 12 * scaleY);
    path2.lineTo(12 * scaleX, 12 * scaleY);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
