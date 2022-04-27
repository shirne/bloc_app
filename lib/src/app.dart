import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../generated/l10n.dart';
import 'app_navigator.dart';
import 'globals/global_bloc.dart';
import 'globals/routes.dart';
import 'utils/utils.dart';

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: () => BlocProvider<GlobalBloc>(
        create: (BuildContext context) => GlobalBloc(GlobalState()),
        child: BlocBuilder<GlobalBloc, GlobalState>(builder: (context, state) {
          return DefaultTextStyle(
            style: const TextStyle(fontFamily: '微软雅黑'),
            child: MaterialApp(
              restorationScopeId: 'app',
              navigatorKey: navigatorKey,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', ''), // English, no country code
              ],
              onGenerateTitle: (BuildContext context) => S.of(context).appTitle,
              theme: _lightTheme(),
              darkTheme: _darkTheme(),
              themeMode: state.themeMode,
              debugShowCheckedModeBanner: false,
              scrollBehavior: _CustomScrollBehavior(),
              navigatorObservers: [
                AppNavigatorObserver(navigatorKey),
              ],
              onGenerateRoute: (RouteSettings routeSettings) {
                final route = Routes.match(routeSettings);
                if (route.isAuth) {
                  if (state.user?.isValid ?? false) {
                    log.d(state.user);
                    return MaterialPageRoute<dynamic>(
                      settings: RouteSettings(
                        name: '/login',
                        arguments: routeSettings,
                      ),
                      builder: (BuildContext context) {
                        return Routes.matchByName('/login')
                            .builder
                            .call(routeSettings);
                      },
                    );
                  }
                  // TODO: 这里是指纹验证逻辑
                  // } else if (state.needVerify) {
                  //   Api.lock();
                  //   Auth.isAuthenticate().then((value) {
                  //     bloc.add(UserVerifyEvent(value == authResult.auth));
                  //   });
                  // }
                }
                return MaterialPageRoute<dynamic>(
                  settings: routeSettings,
                  builder: (BuildContext context) {
                    return route.builder.call(routeSettings);
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5AA7A7),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5AA7A7),
        brightness: Brightness.dark,
      ),
    );
  }
}

/// 支持windows平台的鼠标手势滑动
class _CustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior scrollbar
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}
