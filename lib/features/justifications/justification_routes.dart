import 'package:flutter/material.dart';
import 'presentation/pages/justification_list_page.dart';
import 'presentation/pages/justification_detail_page.dart';
import 'domain/justification_model.dart';

abstract final class JustificationRoutes {
  static const String list = '/justifications';
  static const String detail = '/justifications/detail';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case list:
        return MaterialPageRoute(
          builder: (context) => const JustificationListPage(),
        );
      case detail:
        final justification = settings.arguments as Justification;
        return MaterialPageRoute(
          builder: (context) => JustificationDetailPage(justification: justification),
        );
      default:
        return null;
    }
  }
}
