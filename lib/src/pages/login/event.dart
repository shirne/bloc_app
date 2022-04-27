part of 'bloc.dart';

@immutable
abstract class LoginEvent {}

class RefreshEvent extends LoginEvent {
  final void Function(String message)? onError;
  RefreshEvent({this.onError});
}

class StateChangedEvent extends LoginEvent {
  final LoginState state;
  StateChangedEvent(this.state);
}

