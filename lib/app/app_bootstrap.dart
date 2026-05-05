import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import '../features/resources/screens/resource_detail_screen.dart';
import '../features/resources/screens/add_document_screen.dart';

class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Syndory Prof',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const ResourceDetailScreen(),
    );
  }
}
