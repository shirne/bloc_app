part of 'bloc.dart';

@immutable
class ProfileState extends BaseState {
  ProfileState({
    super.status,
    super.message,
  });

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
