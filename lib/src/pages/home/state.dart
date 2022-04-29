part of 'bloc.dart';

@immutable
class HomeState extends BaseState {
  final int count;

  HomeState({
    Status status = Status.initial,
    this.count = 0,
  }) : super(status: status);

  @override
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
