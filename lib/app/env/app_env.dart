import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppEnv {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Continue silently if .env is missing. It might be loaded from dart-define.
    }
  }

  static String get supabaseUrl {
    const fromEnv = String.fromEnvironment('SUPABASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromEnv.isNotEmpty) return fromEnv;
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static bool get hasSupabaseConfig {
    return supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
  }

  static String dotenvString(String key, [String defaultValue = '']) {
    return dotenv.env[key] ?? defaultValue;
  }

  static bool dotenvBool(String key, [bool defaultValue = false]) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return value.toLowerCase() == 'true' || value == '1';
  }
}
