part of 'bloc.dart';

@immutable
class SettingsState extends BaseState {
  SettingsState({super.status});

  @override
  SettingsState clone({Status? status}) {
    return SettingsState(status: status ?? this.status);
  }
}
