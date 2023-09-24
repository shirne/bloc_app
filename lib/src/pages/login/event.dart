part of 'bloc.dart';

@immutable
abstract class LoginEvent {}

class RefreshEvent extends LoginEvent {
  RefreshEvent({this.onError});

  final void Function(String message)? onError;
}

class StateChangedEvent extends LoginEvent {
  StateChangedEvent(this.state);

  final LoginState state;
}

class SubmitEvent extends LoginEvent {}
