import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import '../models/base.dart';

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
  static const messageError = '_ERROR';

  BaseState({this.status = Status.initial, String? message})
      : message = message == null || message.isEmpty ? null : message;

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
class QueryModel<T, S> {
  const QueryModel({
    this.page = 0,
    this.pageSize = 10,
    this.total = 0,
    this.keyword = '',
    this.type,
    this.status,
  });

  static const _default = QueryModel();

  final int page;
  final int pageSize;
  final int total;
  final String keyword;
  final T? type;
  final S? status;

  QueryModel<T, S> clone({
    int? page,
    int? pageSize,
    int? total,
    String? keyword,
    T? type,
    S? status,
  }) {
    return QueryModel(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      keyword: keyword ?? this.keyword,
      type: type ?? this.type,
      status: status ?? this.status,
    );
  }

  QueryModel<T, S> fromPaged({
    ModelPage? paged,
  }) {
    return clone(
      page: paged?.page,
      pageSize: paged?.pageSize,
      total: paged?.total,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'pageSize': pageSize,
        'total': total,
        'keyword': keyword,
        'type': '$type',
        'status': '$status',
      };
}

class PagedState<T, S extends QueryModel> extends BaseState {
  PagedState({
    Status? status,
    super.message,
    S? query,
    List<T>? lists,
  })  : assert(
          query != null || S == QueryModel,
          'Must specify a query instance when not use default QueryModel',
        ),
        query = query ?? (QueryModel._default as S),
        lists = lists ?? [],
        super(status: status ?? Status.initial);

  final S query;

  final List<T> lists;

  bool get hasMore =>
      lists.length < query.total && query.page < query.total / query.pageSize;
  bool get isFirstLoading => (isInitial || isLoading) && lists.isEmpty;
  bool get isMoreLoading => isLoading && lists.isNotEmpty;
  bool get isEmpty => (isSuccess || isError) && lists.isEmpty;

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

  final String globalKey;

  static void clearCache() {
    _states.clear();
  }

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
