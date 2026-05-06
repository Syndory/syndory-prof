import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:intl/date_symbol_data_local.dart';

import 'theme/app_theme.dart';
import '../features/debug_health/debug_health_screen.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      theme: AppTheme.light,
      locale: const Locale('fr', 'FR'),                    
      supportedLocales: const [Locale('fr', 'FR')],        
      localizationsDelegates: const [                      
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => child ?? const SizedBox.shrink(),
      home: const DebugHealthScreen(),
    );
  }
}
