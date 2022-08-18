import 'dart:async';

import 'package:flutter/widgets.dart';

import 'utils/utils.dart';

enum RouteEventType {
  pop,
  push,
  remove,
  replace,
  startUserGesture,
  stopUserGesture,
}

class RouteEvent {
  final RouteEventType type;
  final Route? route;
  final Route? previousRoute;
  const RouteEvent(this.type, {this.route, this.previousRoute});
}

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  static final _stream = StreamController<RouteEvent>.broadcast()
    ..stream.listen(_routeLogger);
  static StreamSubscription<RouteEvent> on(void Function(RouteEvent)? onData) {
    return _stream.stream.listen(onData);
  }

  static void _routeLogger(RouteEvent e) {
    log.d(
      '${e.type.name} '
      '${e.route?.settings.name ?? (e.previousRoute == null ? '' : '[empty]')}'
      '${e.route == null && e.previousRoute == null ? '' : ' => '}'
      '${e.previousRoute?.settings.name ?? (e.route == null ? '' : '[empty]')}',
    );
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    _stream.add(RouteEvent(
      RouteEventType.pop,
      route: route,
      previousRoute: previousRoute,
    ));
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    _stream.add(RouteEvent(
      RouteEventType.push,
      route: route,
      previousRoute: previousRoute,
    ));
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _stream.add(RouteEvent(
      RouteEventType.remove,
      route: route,
      previousRoute: previousRoute,
    ));
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _stream.add(RouteEvent(
      RouteEventType.replace,
      route: newRoute,
      previousRoute: oldRoute,
    ));
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    _stream.add(RouteEvent(
      RouteEventType.startUserGesture,
      route: route,
      previousRoute: previousRoute,
    ));
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    _stream.add(const RouteEvent(
      RouteEventType.stopUserGesture,
    ));
  }
}
