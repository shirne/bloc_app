import 'package:flutter/material.dart';

import '../pages/home/page.dart';
import '../pages/login/page.dart';
import '../pages/not_found.dart';
import '../pages/settings/page.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class Routes {
  static final root = RouteItem(
    '/',
    (RouteSettings settings) => const HomePage(),
  );
  static final login = RouteItem(
    '/login',
    (RouteSettings settings) => const LoginPage(),
  );
  static final seettings = RouteItem(
    '/settings',
    (RouteSettings settings) => const SettingsPage(),
  );
  static final notFound = RouteItem(
    '/404',
    (RouteSettings settings) => NotFoundPage(settings.name),
  );

  static final routes = {
    for (RouteItem e in [
      root,
      login,
      seettings,
    ])
      e.name: e
  };

  static RouteItem matchByName(String name) {
    return (routes[name] ?? routes['/404'])!;
  }

  static RouteItem match(RouteSettings settings) {
    return settings.name == null
        ? routes['/404']!
        : matchByName(settings.name!);
  }

  static navigateTo(BuildContext context, RouteSettings settings) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        settings: settings,
        builder: (BuildContext context) {
          return match(settings).builder.call(settings);
        },
      ),
    );
  }
}

class RouteItem {
  final bool isAuth;
  final String name;
  final Widget Function(RouteSettings) builder;

  const RouteItem(this.name, this.builder, {this.isAuth = true});

  Future<T?> show<T>(BuildContext context, {Object? arguments}) {
    return Navigator.of(context).pushNamed<T>(name, arguments: arguments);
  }
}
