part of 'bloc.dart';

@immutable
abstract class ProductEvent {}

class RefreshEvent extends ProductEvent {
  RefreshEvent({this.onError});

  final void Function(String message)? onError;
}

class StateChangedEvent extends ProductEvent {
  StateChangedEvent(this.state);
  
  final ProductState state;
}
