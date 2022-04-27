import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

enum Status {
  initial,
  loading,
  success,
  failure,
}

abstract class CachedBloc<E, T> extends Bloc<E, T> {
  final String globalKey;
  static Map<String, dynamic> states = {};

  @mustCallSuper
  CachedBloc(T Function() createState, [this.globalKey = ''])
      : super(globalKey.isEmpty
            ? createState()
            : states.putIfAbsent(globalKey, createState));

  @override
  Future<void> close() async {
    if (globalKey.isNotEmpty) {
      states[globalKey] = state;
    }
    await super.close();
  }
}
