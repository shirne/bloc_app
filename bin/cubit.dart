import 'dart:io';

void main(List<String> args) {
  final dir = args.length > 1 ? args[1] : '';
  final page = args[0];
  final lowerPage = page
      .replaceFirstMapped(
        RegExp('^[A-Z]'),
        (item) => item.group(0)!.toLowerCase(),
      )
      .replaceAllMapped(
        RegExp('[A-Z]+'),
        (match) => '_${match.group(0)!.toLowerCase()}',
      );

  final pageDir = "${Directory.current.path}/lib/src/pages/"
      '${dir.isEmpty ? '' : ('$dir/')}$lowerPage/';
  final pathDeeper = dir.isEmpty ? '' : '../' * dir.split('/').length;
  Directory(pageDir).createSync(recursive: true);

  File('${pageDir}cubit.dart').writeAsStringSync("""
import 'package:flutter/widgets.dart';

import '../../${pathDeeper}common.dart';

part 'state.dart';

class ${page}Cubit extends CachedCubit<${page}State> {
  ${page}Cubit([String globalKey = '']) : super(() => ${page}State(), globalKey) {
    loadData();
  }
  
  Future<void> loadData({void Function(String message)? onError}) async {
    emit(state.clone(status: Status.loading));
    await Future.delayed(const Duration(milliseconds: 500));
    //TODO load data
    if(isClosed){
      return;
    }
    emit(state.clone(status: Status.success));
  }
}
""");

  File('${pageDir}state.dart').writeAsStringSync("""
part of 'cubit.dart';

@immutable
class ${page}State extends BaseState {
  ${page}State({
    super.status = Status.initial,
    super.message,
  });

  @override
  ${page}State clone({
    Status? status,
    String? message,
  }) {
    return ${page}State(
      status: status ?? this.status,
      message: message,
    );
  }
}
""");
  File('${pageDir}view.dart').writeAsStringSync("""
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletons/skeletons.dart';

import '../../${pathDeeper}common.dart';
import 'cubit.dart';

class ${page}View extends StatelessWidget {
  const ${page}View({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<${page}Cubit>(
      create: (context) => ${page}Cubit(),
      child: Container(
        child: BlocBuilder<${page}Cubit, ${page}State>(
          builder: (context, state) {
            // 初始化状态可以显示skeleton
            if (state.isInitial) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) => SkeletonListTile()),
              );
            }

            return const Center(
              child: Text('$page'),
            );
          },
        ),
      ),
    );
  }
}
""");
  stdout.writeln('Create $page ok');
}
