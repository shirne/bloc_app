part of 'bloc.dart';

@immutable
abstract class SystemUIModeEvent {}

class RefreshEvent extends SystemUIModeEvent {
  RefreshEvent({this.onError});

  final void Function(String message)? onError;
}

class StateChangedEvent extends SystemUIModeEvent {
  StateChangedEvent(this.state);
  
  final SystemUIModeState state;
}
