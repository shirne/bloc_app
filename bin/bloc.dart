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

  File('${pageDir}bloc.dart').writeAsStringSync("""
import 'package:flutter/widgets.dart';

import '../../${pathDeeper}common.dart';

part 'event.dart';
part 'state.dart';

class ${page}Bloc extends CachedBloc<${page}Event, ${page}State> {
  ${page}Bloc([String globalKey = '']) : super(() => ${page}State(), globalKey) {
    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });
    
    on<RefreshEvent>((event, emit) {
      emit(state.clone(status: Status.loading));
      _loadData(onError: event.onError);
    });
    
    _loadData();
  }
  
  Future<void> _loadData({void Function(String message)? onError}) async {
    add(StateChangedEvent(state.clone(status: Status.loading)));
    await Future.delayed(const Duration(milliseconds: 500));
    //TODO load data
    if(isClosed){
      return;
    }
    add(StateChangedEvent(state.clone(status: Status.success)));
  }
}
""");
  File('${pageDir}event.dart').writeAsStringSync("""
part of 'bloc.dart';

@immutable
abstract class ${page}Event {}

class RefreshEvent extends ${page}Event {
  RefreshEvent({this.onError});

  final void Function(String message)? onError;
}

class StateChangedEvent extends ${page}Event {
  StateChangedEvent(this.state);
  
  final ${page}State state;
}
""");
  File('${pageDir}state.dart').writeAsStringSync("""
part of 'bloc.dart';

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
  File('${pageDir}page.dart').writeAsStringSync("""
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletons/skeletons.dart';

import '../../${pathDeeper}common.dart';
import 'bloc.dart';

class ${page}Page extends StatelessWidget {
  const ${page}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<${page}Bloc>(
      create: (context) => ${page}Bloc(),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocBuilder<${page}Bloc, ${page}State>(
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
