part of 'bloc.dart';

@immutable
abstract class SettingsEvent {}

class RefreshEvent extends SettingsEvent {
  final void Function(String message)? onError;
  RefreshEvent({this.onError});
}

class StateChangedEvent extends SettingsEvent {
  final SettingsState state;
  StateChangedEvent(this.state);
}
