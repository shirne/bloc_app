import 'dart:convert';

import 'package:bloc/bloc.dart';

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
  BaseState({this.status = Status.initial, this.message});

  final Status status;
  final String? message;

  bool get isInitial => status == Status.initial;
  bool get isSuccess => status == Status.success;
  bool get isLoading => status == Status.loading;
  bool get isError => status == Status.failure;

  BaseState clone();

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
      };

  @override
  String toString() => jsonEncode(toJson());
}

final _states = <String, dynamic>{};

abstract class CachedBloc<E, T extends BaseState> extends Bloc<E, T> {
  final String globalKey;

  CachedBloc(
    T Function() createState, [
    this.globalKey = '',
    T Function(T)? fromCache,
  ]) : super(
          globalKey.isEmpty
              ? createState()
              : fromCache == null
                  ? _states.putIfAbsent(globalKey, createState)
                  : fromCache.call(_states.putIfAbsent(globalKey, createState)),
        );

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

  CachedCubit(
    T Function() createState, [
    this.globalKey = '',
    T Function(T)? fromCache,
  ]) : super(
          globalKey.isEmpty
              ? createState()
              : fromCache == null
                  ? _states.putIfAbsent(globalKey, createState)
                  : fromCache.call(_states.putIfAbsent(globalKey, createState)),
        );

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
