import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/debug_health/debug_health_screen.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      builder: (context, child) => child ?? const SizedBox.shrink(),
      home: const DebugHealthScreen(),
    );
  }
}
