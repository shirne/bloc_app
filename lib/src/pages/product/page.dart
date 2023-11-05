import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletons/skeletons.dart';

import '../../common.dart';
import 'bloc.dart';

/// 产品主页
class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductBloc>(
      create: (context) => ProductBloc(),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            // 初始化状态可以显示skeleton
            if (state.isInitial) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) => SkeletonListTile()),
              );
            }

            return const Center(
              child: Text('Product'),
            );
          },
        ),
      ),
    );
  }
}
