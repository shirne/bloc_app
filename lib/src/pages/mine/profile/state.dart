part of 'bloc.dart';

@immutable
class ProfileState extends BaseState {
  ProfileState({
    Status status = Status.initial,
    String? message,
  }) : super(status: status, message: message);

  @override
  ProfileState clone({
    Status? status,
    String? message,
  }) {
    return ProfileState(
      status: status ?? this.status,
      message: message,
    );
  }
}
