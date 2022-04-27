import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            appBar: AppBar(),
            body: Center(
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
