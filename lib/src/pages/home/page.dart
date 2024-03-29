import 'dart:io';

import 'package:appscheme/appscheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletons/skeletons.dart';

import '../../common.dart';
import 'bloc.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Future(checkScheme);
    }
  }

  void checkScheme() {
    AppScheme? appScheme = AppSchemeImpl.getInstance();
    appScheme?.getInitScheme().then(onScheme);
    appScheme?.registerSchemeListener().listen(onScheme);
  }

  void onScheme(value) {
    if (value != null) {
      logger.info('Init  ${value.dataString}');
      if (value.path != null &&
          value.path != Routes.home.name &&
          value.path != Routes.login.name) {
        Navigator.of(context).pushNamed(value.path!, arguments: value.query);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) => HomeBloc('homestate'),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.appTitle),
              actions: [
                IconButton(
                  onPressed: () {
                    Routes.settings.show(context);
                  },
                  icon: const Icon(Icons.settings),
                ),
              ],
            ),
            body: state.status == Status.initial
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) => SkeletonListTile()),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${state.count}"),
                        ElevatedButton(
                          onPressed: () {
                            Routes.login.show(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(context.l10n.login),
                          ),
                        ),
                      ],
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<HomeBloc>().add(IncreaseEvent(1));
              },
              tooltip: 'Increment',
              enableFeedback: true,
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
