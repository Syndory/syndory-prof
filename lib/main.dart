import 'package:flutter/widgets.dart';

import 'app/env/app_env.dart';
import 'app/app_bootstrap.dart';
import 'data/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppEnv.hasSupabaseConfig) {
    await SupabaseClientProvider.init(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );
  }

  runApp(const AppBootstrap());
}

