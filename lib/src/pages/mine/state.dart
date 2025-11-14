part of 'bloc.dart';

@immutable
class MineState extends BaseState {
  MineState({super.status, super.message});

  @override
  MineState clone({Status? status, String? message}) {
    return MineState(status: status ?? this.status, message: message);
  }
}
