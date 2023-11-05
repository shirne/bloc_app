part of 'bloc.dart';

@immutable
class HomeState extends BaseState {
  final int count;

  HomeState({
    super.status,
    this.count = 0,
  });

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
