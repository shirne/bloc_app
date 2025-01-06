import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import 'app_navigator.dart';
import 'common.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    MyDialog.navigatorKey = navigatorKey;
    return RepositoryProvider<StoreService>(
      create: (_) => StoreService(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<GlobalBloc>(
            create: (BuildContext context) => GlobalBloc(
              context.read<StoreService>(),
            ),
          ),
          BlocProvider<UserBloc>(
            create: (BuildContext context) => UserBloc(
              context.read<StoreService>(),
            ),
          ),
        ],
        child: BlocBuilder<GlobalBloc, GlobalState>(
          builder: (context, state) {
            return DefaultTextStyle(
              // 如果需要内置字体，此处修改为对应的字体名
              style: const TextStyle(fontFamily: '微软雅黑'),
              child: MaterialApp(
                restorationScopeId: 'app',
                navigatorKey: navigatorKey,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ShirneDialogLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                locale: state.locale,
                onGenerateTitle: (c) => c.l10n.appTitle,
                theme: AppTheme.lightTheme(),
                darkTheme: AppTheme.darkTheme(),
                themeMode: state.themeMode,
                debugShowCheckedModeBanner: false,
                scrollBehavior: _CustomScrollBehavior(),
                navigatorObservers: [
                  AppNavigatorObserver(navigatorKey),
                ],
                initialRoute: Routes.splash.name,
                onGenerateRoute: (RouteSettings routeSettings) {
                  final route = Routes.match(routeSettings);
                  if (route == null) {
                    return MaterialPageRoute<dynamic>(
                      settings: RouteSettings(
                        name: Routes.notFound.name,
                        arguments: routeSettings.arguments,
                      ),
                      builder: (BuildContext context) {
                        return Routes.notFound.builder.call(routeSettings.name);
                      },
                    );
                  }
                  if (route.isAuth) {
                    if (UserBloc.hasInstance &&
                        !UserBloc.instance.state.token.isValid) {
                      return MaterialPageRoute<dynamic>(
                        settings: RouteSettings(
                          name: Routes.login.name,
                          arguments: routeSettings.arguments,
                        ),
                        builder: (BuildContext context) {
                          return Routes.login.builder.call({
                            'back': routeSettings.name,
                            'arguments': routeSettings.arguments,
                          });
                        },
                      );
                    }
                    // TODO: 这里是指纹验证逻辑
                    // else if (state.needVerify) {
                    //   Api.lock();
                    //   Auth.isAuthenticate().then((value) {
                    //     bloc.add(UserVerifyEvent(value == authResult.auth));
                    //   });
                    // }
                  }
                  return MaterialPageRoute<dynamic>(
                    settings: routeSettings,
                    builder: (BuildContext context) {
                      return route.builder.call(routeSettings.arguments);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 支持windows平台的鼠标手势滑动
class _CustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior scrollbar
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.unknown,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics()
          .applyTo(const AlwaysScrollableScrollPhysics());
}
