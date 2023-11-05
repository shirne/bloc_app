import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletons/skeletons.dart';

import '../../common.dart';
import 'bloc.dart';

/// 我的(个人中心)
class MinePage extends StatelessWidget {
  const MinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MineBloc>(
      create: (context) => MineBloc(),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<MineBloc, MineState>(
          builder: (context, state) {
            // 初始化状态可以显示skeleton
            if (state.isInitial) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) => SkeletonListTile()),
              );
            }

            return const Center(
              child: Text('Mine'),
            );
          },
        ),
      ),
    );
  }
}
