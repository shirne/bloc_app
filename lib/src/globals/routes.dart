import 'package:flutter/material.dart';

import '../pages/home/page.dart';
import '../pages/login/page.dart';
import '../pages/not_found.dart';
import '../pages/settings/page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class Routes {
  static final root = RouteItem(
    '/',
    (arguments) => const HomePage(),
  );
  static final login = RouteItem(
    '/login',
    (arguments) => LoginPage(arguments as Map<String, dynamic>?),
  );
  static final seettings = RouteItem(
    '/settings',
    (arguments) => const SettingsPage(),
  );
  static final notFound = RouteItem(
    '/404',
    (arguments) => NotFoundPage(arguments as String?),
  );

  static final routes = {
    for (RouteItem e in [
      root,
      login,
      seettings,
    ])
      e.name: e
  };

  static RouteItem? matchByName(String? name) {
    return routes[name];
  }

  static RouteItem? match(RouteSettings settings) {
    return matchByName(settings.name);
  }
}

class RouteItem {
  final bool isAuth;
  final String name;
  final Widget Function(Object? arguments) builder;

  const RouteItem(this.name, this.builder, {this.isAuth = true});

  Future<T?> show<T>(BuildContext context, {Object? arguments}) {
    return Navigator.of(context).pushNamed<T>(name, arguments: arguments);
  }

  Future<T?> replace<T>(BuildContext context, {Object? arguments}) {
    return Navigator.of(context)
        .pushReplacementNamed<T, Object>(name, arguments: arguments);
  }
}
