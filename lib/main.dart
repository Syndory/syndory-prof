import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'app/env/app_env.dart';
import 'app/app_bootstrap.dart';
import 'data/supabase/supabase_client.dart';
import 'package:syndory_prof/features/resources/screens/add_document_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (AppEnv.hasSupabaseConfig) {
    await SupabaseClientProvider.init(
      url: AppEnv.supabaseUrl,
      anonKey: AppEnv.supabaseAnonKey,
    );
  }

  // runApp(const AppBootstrap());
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF001F3F),
      ),
      home: const AddDocumentScreen(), 
    ),
  );

}

