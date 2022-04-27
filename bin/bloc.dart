// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) {
  final dir = args.length > 1 ? args[1] : '';
  final page = args[0];
  final lowerPage = page
      .replaceFirstMapped(
          RegExp('^[A-Z]'), (item) => item.group(0)!.toLowerCase())
      .replaceAllMapped(
          RegExp('[A-Z]+'), (match) => '_' + match.group(0)!.toLowerCase());

  final pagedir = Directory.current.path +
      "/lib/src/pages/" +
      (dir.isEmpty ? '' : (dir + '/')) +
      lowerPage +
      '/';
  final pathDepper = dir.isEmpty ? '' : '../' * dir.split('/').length;
  Directory(pagedir).createSync(recursive: true);

  File(pagedir + 'bloc.dart').writeAsStringSync("""
import 'package:flutter/widgets.dart';
import 'package:skeletons/skeletons.dart';

import '../../${pathDepper}widgets/cached_bloc.dart';

part 'event.dart';
part 'state.dart';

class ${page}Bloc extends CachedBloc<${page}Event, ${page}State> {
  
  ${page}Bloc([String globalKey = ''])
      : super(() => const ${page}State(), globalKey) {
    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });
    
    on<RefreshEvent>((event, emit) {
      emit(state.clone(status: Status.loading));
      _loadData(onError: event.onError);
    });
    
    _loadData();
  }
  
  _loadData({void Function(String message)? onError}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    //TODO load data
    if(isClosed){
      return;
    }
  }
}

""");
  File(pagedir + 'event.dart').writeAsStringSync("""
part of 'bloc.dart';

@immutable
abstract class ${page}Event {}

class RefreshEvent extends ${page}Event {
  final void Function(String message)? onError;
  RefreshEvent({this.onError});
}

class StateChangedEvent extends ${page}Event {
  final ${page}State state;
  StateChangedEvent(this.state);
}

""");
  File(pagedir + 'state.dart').writeAsStringSync("""
part of 'bloc.dart';

@immutable
class ${page}State {
  final Status status;

  const ${page}State({
    this.status = Status.initial,
  });

  ${page}State clone({
    Status? status,
  }) {
    return ${page}State(
      status: status ?? this.status,
    );
  }
}

""");
  File(pagedir + 'page.dart').writeAsStringSync("""
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc.dart';

class ${page}Page extends StatelessWidget {
  const ${page}Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<${page}Bloc>(
      create: (context) => ${page}Bloc(),
      child: BlocBuilder<${page}Bloc, ${page}State>(
        builder: (context, state) {
          // 初始化状态可以显示skeleton
          if(state.status == Status.initial){
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) => SkeletonListTile()),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body:Center(
              child:Text('$page'),
            ),
          );
        },
      ),
    );
  }
}


""");
  print('create $page ok');
}
