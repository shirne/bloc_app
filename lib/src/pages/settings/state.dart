part of 'bloc.dart';

@immutable
class SettingsState {
  final Status status;

  const SettingsState({
    this.status = Status.initial,
  });

  SettingsState clone({
    Status? status,
  }) {
    return SettingsState(
      status: status ?? this.status,
    );
  }
}

