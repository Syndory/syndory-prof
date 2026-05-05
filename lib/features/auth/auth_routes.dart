import 'package:flutter/material.dart';

import 'placeholder.dart';

abstract final class AuthRoutes {
  static const String login = '/auth/login';

  static Widget loginScreen(BuildContext context) {
    return const AuthPlaceholderScreen();
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (context) => loginScreen(context));
      default:
        return null;
    }
  }
}
