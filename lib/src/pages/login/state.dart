part of 'bloc.dart';

@immutable
class LoginState extends BaseState {
  LoginState({
    Status status = Status.initial,
  }) : super(status: status);

  @override
  LoginState clone({
    Status? status,
  }) {
    return LoginState(
      status: status ?? this.status,
    );
  }
}
