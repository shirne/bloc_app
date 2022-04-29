import 'package:bloc/bloc.dart';
import 'package:blocapp/src/globals/store_service.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import 'api_service.dart';

abstract class GlobalEvent {}

class ThemeModeChangedEvent extends GlobalEvent {
  final ThemeMode themeMode;
  ThemeModeChangedEvent(this.themeMode);
}

class UserAuthEvent extends GlobalEvent {
  final bool authed;
  UserAuthEvent(this.authed);
}

class UserLoginEvent extends GlobalEvent {
  final User user;
  UserLoginEvent(this.user);
}

class UserQuitEvent extends GlobalEvent {}

class GlobalState {
  final User user;
  final ThemeMode themeMode;
  GlobalState({User? user, this.themeMode = ThemeMode.system})
      : user = user ?? User();

  GlobalState clone({
    User? user,
    ThemeMode? themeMode,
    bool hasUser = false,
  }) {
    return GlobalState(
      user: user ?? (hasUser ? null : this.user),
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc(StoreService storeService)
      : super(GlobalState(
          user: storeService.user(),
          themeMode: storeService.themeMode(),
        )) {
    on<ThemeModeChangedEvent>((event, emit) {
      emit(state.clone(themeMode: event.themeMode));
    });

    on<UserAuthEvent>((event, emit) {
      if (event.authed) {
        emit(state.clone(user: state.user..isAuthed = true));
      } else {
        emit(state.clone(user: User()));
      }
    });

    on<UserLoginEvent>((event, emit) {
      ApiService.getInstance().addHeader('token', event.user.token);
      emit(state.clone(user: event.user));
    });

    on<UserQuitEvent>((event, emit) {
      ApiService.getInstance().removeHeader('token');
      emit(state.clone(user: User()));
    });

    if (state.user.isValid) {
      ApiService.getInstance().addHeader('token', state.user.token);
    }
  }
}
