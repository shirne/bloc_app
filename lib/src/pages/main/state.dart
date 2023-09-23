part of 'bloc.dart';

enum FilterType {
  activity,
  carpool,
}

@immutable
class MainState extends BaseState {
  MainState({
    Status status = Status.initial,
    String? message,
    this.isSearch = false,
  }) : super(status: status, message: message);

  final bool isSearch;

  @override
  MainState clone({
    Status? status,
    String? message,
    bool? isSearch,
    FilterType? filterType,
  }) {
    return MainState(
      status: status ?? this.status,
      message: message,
      isSearch: isSearch ?? false,
    );
  }
}
