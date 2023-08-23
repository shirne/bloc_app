import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

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

@immutable
class QueryModel {
  const QueryModel({
    this.page = 1,
    this.pageSize = 10,
    this.total = 0,
    this.keyword = '',
  });

  static const _default = QueryModel();

  final int page;
  final int pageSize;
  final int total;
  final String keyword;

  QueryModel clone({
    int? page,
    int? pageSize,
    int? total,
    String? keyword,
  }) {
    return QueryModel(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      keyword: keyword ?? this.keyword,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'pageSize': pageSize,
        'total': total,
        'keyword': keyword,
      };
}

class PagedState<T, S extends QueryModel> extends BaseState {
  PagedState({
    Status? status,
    String? message,
    S? query,
    List<T>? lists,
  })  : assert(
          query != null || S == QueryModel,
          'Must specify a query instance when not use default QueryModel',
        ),
        query = query ?? (QueryModel._default as S),
        lists = lists ?? [],
        super(status: status ?? Status.initial, message: message);

  final S query;

  final List<T> lists;

  bool get hasMore => lists.length < query.total;
  bool get isFirstLoading => isLoading && lists.isEmpty;
  bool get isEmpty => (isSuccess || isError) & lists.isEmpty;

  @override
  PagedState<T, S> clone({
    Status? status,
    String? message,
    S? query,
    List<T>? lists,
  }) {
    return PagedState(
      status: status ?? this.status,
      message: message ?? this.message,
      query: query ?? this.query,
      lists: lists ?? this.lists,
    );
  }

  @override
  Map<String, dynamic> toJson() => super.toJson()
    ..addAll({
      'query': query,
      'lists': lists,
    });
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
