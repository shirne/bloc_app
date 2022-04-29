part of 'bloc.dart';

@immutable
class SettingsState extends BaseState {
  SettingsState({
    Status status = Status.initial,
  }) : super(status: status);

  @override
  SettingsState clone({
    Status? status,
  }) {
    return SettingsState(
      status: status ?? this.status,
    );
  }
}
