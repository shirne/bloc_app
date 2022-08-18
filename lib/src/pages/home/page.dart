import 'dart:io';

import 'package:appscheme/appscheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletons/skeletons.dart';

import '../../../generated/l10n.dart';
import '../../globals/routes.dart';
import '../../utils/utils.dart';
import '../../widgets/cached_bloc.dart';
import 'bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
      log.d('Init  ${value.dataString}');
      if (value.path != null &&
          value.path != Routes.root.name &&
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
              title: Text(S.of(context).appTitle),
              actions: [
                IconButton(
                  onPressed: () {
                    Routes.seettings.show(context);
                  },
                  icon: const Icon(Icons.settings),
                )
              ],
            ),
            body: state.status == Status.initial
                ? Padding(
                    padding: EdgeInsets.all(20.w),
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
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Text(S.of(context).login),
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
