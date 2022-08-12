import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

enum Status {
  initial('initial'),
  loading('loading'),
  success('success'),
  failure('failure');

  final String value;
  const Status(this.value);

  String toJson() => value;

  @override
  String toString() => value;
}

abstract class BaseState {
  final Status status;

  BaseState({this.status = Status.initial});

  bool get isInitial => status == Status.initial;
  bool get isSuccess => status == Status.success;
  bool get isLoading => status == Status.loading;
  bool get isError => status == Status.failure;

  clone();

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}

final _states = <String, dynamic>{};

abstract class CachedBloc<E, T extends BaseState> extends Bloc<E, T> {
  final String globalKey;

  @mustCallSuper
  CachedBloc(T Function() createState,
      [this.globalKey = '', T Function(T)? fromCache])
      : super(globalKey.isEmpty
            ? createState()
            : fromCache == null
                ? _states.putIfAbsent(globalKey, createState)
                : fromCache.call(_states.putIfAbsent(globalKey, createState)));

  @override
  Future<void> close() async {
    if (globalKey.isNotEmpty) {
      _states[globalKey] = state;
    }
    await super.close();
  }

  void safeAdd(E event) {
    if (!isClosed) {
      add(event);
    }
  }
}

abstract class CachedCubit<T> extends Cubit<T> {
  final String globalKey;

  @mustCallSuper
  CachedCubit(T Function() createState,
      [this.globalKey = '', T Function(T)? fromCache])
      : super(globalKey.isEmpty
            ? createState()
            : fromCache == null
                ? _states.putIfAbsent(globalKey, createState)
                : fromCache.call(_states.putIfAbsent(globalKey, createState)));

  @override
  Future<void> close() async {
    if (globalKey.isNotEmpty) {
      _states[globalKey] = state;
    }
    await super.close();
  }

  void safeEmit(T state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
