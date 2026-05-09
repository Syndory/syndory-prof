import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'app/env/app_env.dart';
import 'app/app_bootstrap.dart';
import 'data/supabase/supabase_client.dart';

// Dev auto-login flags — injected at compile time via --dart-define or loaded from .env.
// Never active in release builds.
bool get _devAutoLogin {
  const fromEnv = bool.fromEnvironment('DEV_AUTO_LOGIN', defaultValue: false);
  if (fromEnv) return true;
  return AppEnv.dotenvBool('DEV_AUTO_LOGIN');
}

String get _devEmail {
  const fromEnv = String.fromEnvironment('DEV_LOGIN_EMAIL');
  if (fromEnv.isNotEmpty) return fromEnv;
  return AppEnv.dotenvString('DEV_LOGIN_EMAIL', 'prof1@syndory.com');
}

String get _devPassword {
  const fromEnv = String.fromEnvironment('DEV_LOGIN_PASSWORD');
  if (fromEnv.isNotEmpty) return fromEnv;
  return AppEnv.dotenvString('DEV_LOGIN_PASSWORD', 'prof123');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();

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

  runApp(const ProviderScope(child: AppBootstrap()));
}
