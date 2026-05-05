import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:syndory_prof/features/calendrier/navigationbar.dart';

// import 'app/env/app_env.dart';
// import 'app/app_bootstrap.dart';
// import 'data/supabase/supabase_client.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   if (AppEnv.hasSupabaseConfig) {
//     await SupabaseClientProvider.init(
//       url: AppEnv.supabaseUrl,
//       anonKey: AppEnv.supabaseAnonKey,
//     );
//   }

//   runApp(const AppBootstrap());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise les locales pour le français
  await initializeDateFormatting('fr_FR');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My App'),
        ),
        body: const MyNavigationBar(),
      ),
    );
  }
}