part of 'bloc.dart';

@immutable
abstract class ProfileEvent {}

class RefreshEvent extends ProfileEvent {
  RefreshEvent({this.onError});

  final void Function(String message)? onError;
}

class StateChangedEvent extends ProfileEvent {
  StateChangedEvent(this.state);
  
  final ProfileState state;
}
