part of 'bloc.dart';

@immutable
class ProductState extends BaseState {
  ProductState({super.status, super.message});

  @override
  ProductState clone({Status? status, String? message}) {
    return ProductState(status: status ?? this.status, message: message);
  }
}
