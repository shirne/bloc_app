part of 'bloc.dart';

@immutable
abstract class HomeEvent {}

class RefreshEvent extends HomeEvent {
  final void Function(String message)? onError;
  RefreshEvent({this.onError});
}

class StateChangedEvent extends HomeEvent {
  final HomeState state;
  StateChangedEvent(this.state);
}

class IncreaseEvent extends HomeEvent {
  final int increase;
  IncreaseEvent(this.increase);
}
