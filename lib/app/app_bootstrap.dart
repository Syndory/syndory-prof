import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../app/navigation/main_shell.dart';
import '../features/justifications/justification_list_page.dart'; // ← ajouter

const bool _devJustifPreview = bool.fromEnvironment('DEV_JUSTIF_PREVIEW'); // ← ajouter

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      home: _devJustifPreview
          ? const JustificationListPage() // ← ajouter
          : const MainShell(),
    );
  }
}