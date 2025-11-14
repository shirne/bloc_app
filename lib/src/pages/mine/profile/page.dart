import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletons/skeletons.dart';

import '../../../common.dart';
import 'bloc.dart';

/// 我的资料
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc(),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // 初始化状态可以显示skeleton
            if (state.isInitial) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) => SkeletonListTile()),
              );
            }

            return const Center(child: Text('Profile'));
          },
        ),
      ),
    );
  }
}
