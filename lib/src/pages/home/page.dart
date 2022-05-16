import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletons/skeletons.dart';

import '../../../generated/l10n.dart';
import '../../globals/routes.dart';
import '../../widgets/cached_bloc.dart';
import 'bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

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
                  icon: Icon(Icons.settings),
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
                            child: Text('登录'),
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
