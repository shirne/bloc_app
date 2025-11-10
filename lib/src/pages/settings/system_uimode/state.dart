part of 'bloc.dart';

@immutable
class SystemUIModeState extends BaseState {
  SystemUIModeState({
    super.status = Status.initial,
    super.message,
    this.contrastEnforced = false,
  });

  final bool contrastEnforced;

  @override
  SystemUIModeState clone({
    Status? status,
    String? message,
    bool? contrastEnforced,
  }) {
    return SystemUIModeState(
      status: status ?? this.status,
      message: message,
      contrastEnforced: contrastEnforced ?? this.contrastEnforced,
    );
  }
}
