part of 'bloc.dart';

@immutable
class MineState extends BaseState {
  MineState({
    Status status = Status.initial,
    String? message,
  }) : super(status: status, message: message);

  @override
  MineState clone({
    Status? status,
    String? message,
  }) {
    return MineState(
      status: status ?? this.status,
      message: message,
    );
  }
}
