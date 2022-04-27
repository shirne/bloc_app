part of 'bloc.dart';

@immutable
class HomeState {
  final Status status;
  final int count;

  const HomeState({
    this.status = Status.initial,
    this.count = 0,
  });

  HomeState clone({
    Status? status,
    int? count,
  }) {
    return HomeState(
      status: status ?? this.status,
      count: count ?? this.count,
    );
  }
}
