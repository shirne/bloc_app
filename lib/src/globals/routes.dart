import 'package:flutter/material.dart';

import '../common.dart';
import '../pages/policy.dart';
import '../pages/splash.dart';
import '../pages/not_found.dart';
// ==== GENERATED IMPORT START ====
import '../pages/home/page.dart';
import '../pages/login/page.dart';
import '../pages/settings/page.dart';
import '../pages/web/page.dart';
// ==== GENERATED END ====

final navigatorKey = GlobalKey<NavigatorState>();
final l10n = AppLocalizations.of(navigatorKey.currentContext!)!;

class Routes {
  static final splash = RouteItem(
    '/',
    (arguments) => const SplashPage(),
  );
  static final policy = RouteItem(
    '/policy',
    (arguments) => PolicyPage(arguments as Json?),
  );
  static final notFound = RouteItem(
    '/404',
    (arguments) => NotFoundPage(arguments as String?),
  );

// ==== GENERATED ROUTES START ====

  static final home = RouteItem(
    '/home',
    (arguments) => const HomePage(),
  );
  static final login = RouteItem(
    '/login',
    isAuth: false,
    (arguments) => LoginPage(arguments as Json?),
  );
  static final settings = RouteItem(
    '/settings',
    (arguments) => const SettingsPage(),
  );
  static final web = RouteItem(
    '/web',
    (arguments) => WebViewPage(arguments as Json?),
  );

  static final routes = {
    for (RouteItem e in [
      splash,
      policy,
      home,
      login,
      settings,
      web,
    ])
      e.name: e
  };
// ==== GENERATED END ====

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
