part of 'bloc.dart';

@immutable
abstract class MineEvent {}

class RefreshEvent extends MineEvent {
  RefreshEvent({this.onError});

  final void Function(String message)? onError;
}

class StateChangedEvent extends MineEvent {
  StateChangedEvent(this.state);
  
  final MineState state;
}
