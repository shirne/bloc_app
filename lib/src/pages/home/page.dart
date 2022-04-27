import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletons/skeletons.dart';

import '../../../generated/l10n.dart';
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
            ),
            body: state.status == Status.initial
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (index) => SkeletonListTile()),
                  )
                : Center(
                    child: Text("${state.count}"),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.read<HomeBloc>().add(IncreaseEvent(1));
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
