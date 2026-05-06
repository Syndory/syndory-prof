import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../app/navigation/main_shell.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      home: const MainShell(),
    );
  }
}
