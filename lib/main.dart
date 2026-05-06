import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

import 'app/env/app_env.dart';
import 'app/app_bootstrap.dart';
import 'data/supabase/supabase_client.dart';

// Dev auto-login flags — injected at compile time via --dart-define.
// Never active in release builds.
const bool _devAutoLogin = bool.fromEnvironment('DEV_AUTO_LOGIN');
const String _devEmail = String.fromEnvironment('DEV_LOGIN_EMAIL');
const String _devPassword = String.fromEnvironment('DEV_LOGIN_PASSWORD');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppEnv.hasSupabaseConfig) {
    await SupabaseClientProvider.init(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );

    // Auto sign-in with email/password so the dev skips the login screen.
    // Only runs when DEV_AUTO_LOGIN=true is passed via --dart-define,
    // and only in non-release builds.
    if (_devAutoLogin &&
        !kReleaseMode &&
        _devEmail.isNotEmpty &&
        _devPassword.isNotEmpty) {
      try {
        await SupabaseClientProvider.client.auth.signInWithPassword(
          email: _devEmail,
          password: _devPassword,
        );
      } catch (e) {
        // Boot continues — AuthGate will show the login screen as fallback.
        debugPrint('[DEV] Auto-login failed: $e');
      }
    }
  }

  runApp(const AppBootstrap());
}

