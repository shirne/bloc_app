part of 'bloc.dart';

@immutable
abstract class MainEvent {}

class RefreshEvent extends MainEvent {
  RefreshEvent({this.onError});

  final void Function(String message)? onError;
}

class StateChangedEvent extends MainEvent {
  final MainState state;
  StateChangedEvent(this.state);
}
