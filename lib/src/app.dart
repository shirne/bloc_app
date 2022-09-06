import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:blocapp/src/common.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'app_navigator.dart';

enum SortType {
  newst(200),
  hot(300);

  final int sort;
  const SortType(this.sort);
}

class MainApp extends StatelessWidget {
  final StoreService storeService;
  const MainApp(this.storeService, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MyDialog.navigatorKey = navigatorKey;
    return ScreenUtilInit(
      designSize: const Size(1080, 1920),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return child!;
      },
      child: BlocProvider<GlobalBloc>(
        create: (BuildContext context) => GlobalBloc(storeService),
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
                supportedLocales: const [
                  Locale('en'), // English, no country code
                  Locale('zh', 'CN'),
                ],
                onGenerateTitle: (c) => c.l10n.appTitle,
                theme: _lightTheme(),
                darkTheme: _darkTheme(),
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
                      settings:
                          routeSettings.copyWith(name: Routes.notFound.name),
                      builder: (BuildContext context) {
                        return Routes.notFound.builder.call(routeSettings.name);
                      },
                    );
                  }
                  if (route.isAuth) {
                    if (state.user.isValid) {
                      log.d(state.user);
                      return MaterialPageRoute<dynamic>(
                        settings:
                            routeSettings.copyWith(name: Routes.login.name),
                        builder: (BuildContext context) {
                          return Routes.login.builder.call({
                            'back': routeSettings.name,
                            'arguments': routeSettings.arguments,
                          });
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

  ThemeData widgetStyle(ThemeData base, AppTheme extTheme) {
    return base.copyWith(
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      cardTheme: const CardTheme(
        elevation: 20,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: base.colorScheme.surface,
        selectedTileColor: base.colorScheme.primary.withAlpha(20),
      ),
      extensions: [extTheme, const ShirneDialogTheme()],
    );
  }

  ThemeData _lightTheme() {
    final themeData = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5AA7A7),
      ),
    );
    return widgetStyle(themeData, AppTheme());
  }

  ThemeData _darkTheme() {
    final themeData = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5AA7A7),
        brightness: Brightness.dark,
      ),
    );

    return widgetStyle(themeData, AppTheme());
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
}
