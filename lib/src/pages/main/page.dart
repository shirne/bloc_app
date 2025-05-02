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
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = homeTabIndex.value;

  @override
  void initState() {
    super.initState();

    homeTabIndex.addListener(_onChangeTab);
  }

  void _onChangeTab() {
    setState(() {
      index = homeTabIndex.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (!state.token.isValid) {
          logger.info('to login');
          Routes.login.show(context);
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
