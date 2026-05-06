abstract final class AppEnv {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xxcwmwftjliagwykluex.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4Y3dtd2Z0amxpYWd3eWtsdWV4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc1NzQ0MzAsImV4cCI6MjA5MzE1MDQzMH0.rXSTVwdjYjd8zdld6rPOHQsbbtoxy41IJPvlCoo-z7I',
  );

  static bool get hasSupabaseConfig {
    return supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;
  }
}
