part of 'bloc.dart';

@immutable
class ProductState extends BaseState {
  ProductState({
    Status status = Status.initial,
    String? message,
  }) : super(status: status, message: message);

  @override
  ProductState clone({
    Status? status,
    String? message,
  }) {
    return ProductState(
      status: status ?? this.status,
      message: message,
    );
  }
}
