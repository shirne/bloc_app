import 'package:flutter/material.dart';

import '../common.dart';
import '../pages/splash.dart';
import '../pages/policy.dart';
import '../pages/not_found.dart';
// ==== GENERATED IMPORT START ====
import '../pages/home/page.dart';
import '../pages/login/page.dart';
import '../pages/main/page.dart';
import '../pages/mine/page.dart';
import '../pages/mine/profile/page.dart';
import '../pages/product/page.dart';
import '../pages/settings/page.dart';
import '../pages/web/page.dart';
import 'config.dart';
// ==== GENERATED END ====

final navigatorKey = GlobalKey<NavigatorState>();

bool notLoginPage(Route<dynamic> route) {
  return !(route.settings.name?.startsWith('login') ?? false);
}

String? processRoutes(String? url) {
  if (url != null && Config.shareRegexp.hasMatch(url)) {
    if (url.contains('/mine/activity/')) {
      url = url.replaceAll('/mine/activity/', '/mine/activities/');
    } else if (url.contains('/mine/carpool/')) {
      url = url.replaceAll('/mine/carpool/', '/mine/carpools/');
    }
    logger.info('tourl: $url');
    final uri = Uri.parse(url);

    if (uri.path == Routes.main.name) {
      homeTabIndex.value = 0;
    } else if (uri.path == Routes.home.name) {
      homeTabIndex.value = 0;
    } else if (uri.path == Routes.product.name) {
      homeTabIndex.value = 1;
    } else if (uri.path == Routes.mine.name) {
      homeTabIndex.value = 2;
    } else {
      Routes.matchByName(uri.path)
          ?.show(navigatorKey.currentContext!, arguments: uri.queryParameters);
      return null;
    }
    navigatorKey.currentState
        ?.popUntil((route) => route.settings.name == Routes.main.name);

    return null;
  }
  return url;
}

class Routes {
  static final splash = RouteItem(
    '/',
    isAuth: false,
    (arguments) => const SplashPage(),
  );
  static final policy = RouteItem(
    '/policy',
    isAuth: false,
    (arguments) => PolicyPage(arguments as Json?),
  );
  static final notFound = RouteItem(
    '/404',
    isAuth: false,
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
  static final main = RouteItem(
    '/main',
    (arguments) => const MainPage(),
  );
  static final mine = RouteItem(
    '/mine',
    (arguments) => const MinePage(),
  );
  static final mineProfile = RouteItem(
    '/mine/profile',
    (arguments) => const ProfilePage(),
  );
  static final product = RouteItem(
    '/product',
    (arguments) => const ProductPage(),
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
      main,
      mine,
      mineProfile,
      product,
      settings,
      web,
    ])
      e.name: e,
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
