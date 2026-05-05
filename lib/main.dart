import 'package:flutter/widgets.dart';

import 'app/env/app_env.dart';
import 'app/app_bootstrap.dart';
import 'data/supabase/supabase_client.dart';

// Dev auto-login flags passed via --dart-define (compile-time)
const bool _devAutoLogin = bool.fromEnvironment('DEV_AUTO_LOGIN');
const String _devRefreshToken = String.fromEnvironment('DEV_REFRESH_TOKEN');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppEnv.hasSupabaseConfig) {
    await SupabaseClientProvider.init(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );

    // Si on a demandé un auto-login en dev, essaye de restaurer la session via
    // le `refresh_token` (appel sécurisé côté client). Cette logique ne s'exécute
    // que si `DEV_AUTO_LOGIN=true` est passé en `--dart-define`.
    if (_devAutoLogin && _devRefreshToken.isNotEmpty) {
      try {
        await SupabaseClientProvider.client.auth.setSession(_devRefreshToken);
      } catch (e) {
        // Ne bloque pas le démarrage si l'auto-login échoue.
        // Le debug screen restera utile pour diagnostiquer.
      }
    }
  }

  runApp(const AppBootstrap());
}
