import 'dart:io';

import 'package:appscheme/appscheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common.dart';
import '../../pages/home/page.dart';
import '../../widgets/lazy_indexed_stack.dart';
import '../mine/page.dart';
import '../product/page.dart';
import 'bloc.dart';

final homeTabIndex = ValueNotifier(0);

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = homeTabIndex.value;
  bool profilePoped = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Future(checkScheme);
    }

    homeTabIndex.addListener(_onChangeTab);
  }

  void checkScheme() {
    AppScheme? appScheme = AppSchemeImpl.getInstance();
    appScheme?.getInitScheme().then(onScheme);
    appScheme?.registerSchemeListener().listen(onScheme);
  }

  void onScheme(SchemeEntity? value) {
    if (value != null) {
      logger.info('Init  ${value.dataString}');
      if (value.path != null &&
          value.path != Routes.main.name &&
          value.path != Routes.login.name) {
        /// 处理首页tab
        if (value.path == Routes.home.name) {
          homeTabIndex.value = 0;
        } else if (value.path == Routes.product.name) {
          homeTabIndex.value = 1;
        } else if (value.path == Routes.mine.name) {
          homeTabIndex.value = 2;
        } else {
          Navigator.of(context).pushNamed(value.path!, arguments: value.query);
        }
      }
    }
  }

  void _onChangeTab() {
    setState(() {
      index = homeTabIndex.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalBloc, GlobalState>(
      listener: (context, state) {
        if (!state.token.isValid) {
          logger.info('to login');
          Routes.login.show(context);
        } else if (!profilePoped) {
          if (state.user.id != 0 && state.user.nickname.isEmpty) {
            profilePoped = true;
            Future.delayed(const Duration(milliseconds: 300)).then((_) {
              Routes.mineProfile.show(
                context,
                arguments: {
                  'profile': false,
                  'password': false,
                },
              );
            });
          }
        }
      },
      builder: (context, globalState) {
        return BlocProvider<MainBloc>(
          create: (context) => MainBloc(),
          child: Scaffold(
            body: LazyIndexedStack(
              index: index,
              children: const [
                HomePage(),
                ProductPage(),
                MinePage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              onTap: (int i) {
                homeTabIndex.value = i;
              },
              currentIndex: index,
              unselectedItemColor: Colors.grey,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              unselectedFontSize: 12,
              selectedFontSize: 12,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_rounded),
                  label: context.l10n.tabHome,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.apps_rounded),
                  label: context.l10n.tabProduct,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_rounded),
                  label: context.l10n.tabMine,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
