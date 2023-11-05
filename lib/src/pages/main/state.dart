part of 'bloc.dart';

enum FilterType {
  activity,
  carpool,
}

@immutable
class MainState extends BaseState {
  MainState({
    super.status,
    super.message,
    this.isSearch = false,
  });

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
