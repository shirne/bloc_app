import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import 'api.dart';
import 'api_service.dart';
import 'store_service.dart';

typedef ResultCallback<T> = void Function(bool, T? data);

@immutable
abstract class GlobalEvent {}

class ThemeModeChangedEvent extends GlobalEvent {
  final ThemeMode themeMode;
  ThemeModeChangedEvent(this.themeMode);
}

class InitEvent extends GlobalEvent {
  final ResultCallback? onReady;
  InitEvent([this.onReady]);
}

class StateChangedEvent extends GlobalEvent {
  final GlobalState state;
  StateChangedEvent(this.state);
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
      : super(
          GlobalState(
            user: storeService.user(),
            themeMode: storeService.themeMode(),
          ),
        ) {
    on<ThemeModeChangedEvent>((event, emit) {
      emit(state.clone(themeMode: event.themeMode));
    });

    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });

    on<InitEvent>((event, emit) {
      _init(event.onReady);
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
  Future<void> _init([ResultCallback? onReady]) async {
    if (state.user.token.isNotEmpty) {
      if (state.user.isValid) {
        ApiService.getInstance().addHeader('token', state.user.token);
        await _upUserinfo(() {});
      }
    }
    onReady?.call(true, null);
  }

  Future<void> _upUserinfo([VoidCallback? onRequireLogin]) async {
    final result = await Api.getUserinfo(onRequireLogin);
    if (!isClosed && result.success) {
      add(
        StateChangedEvent(
          state.clone(user: result.data!..token = state.user.token),
        ),
      );
    }
  }
}
