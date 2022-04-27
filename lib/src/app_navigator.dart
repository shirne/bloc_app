import 'package:flutter/widgets.dart';

import 'utils/utils.dart';

class AppNavigatorObserver extends NavigatorObserver {
  final GlobalKey<NavigatorState> navigatorKey;

  AppNavigatorObserver(this.navigatorKey);

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    log.d('didPop ${route.settings.name} => ${previousRoute?.settings.name}');
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    log.d('didPush ${route.settings.name} => ${previousRoute?.settings.name}');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    log.d(
        'didRemove ${route.settings.name} => ${previousRoute?.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    log.d(
        'didReplace ${newRoute?.settings.name} => ${oldRoute?.settings.name}');
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    super.didStartUserGesture(route, previousRoute);
    log.d(
        'didStartUserGesture ${route.settings.name} => ${previousRoute?.settings.name}');
  }

  @override
  void didStopUserGesture() {
    super.didStopUserGesture();
    log.d('didStopUserGesture');
  }
}
