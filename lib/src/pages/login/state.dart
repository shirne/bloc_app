part of 'bloc.dart';

@immutable
class LoginState extends BaseState {
  LoginState({super.status});

  @override
  LoginState clone({Status? status}) {
    return LoginState(status: status ?? this.status);
  }
}
