part of 'bloc.dart';

@immutable
class LoginState {
  final Status status;

  const LoginState({
    this.status = Status.initial,
  });

  LoginState clone({
    Status? status,
  }) {
    return LoginState(
      status: status ?? this.status,
    );
  }
}

