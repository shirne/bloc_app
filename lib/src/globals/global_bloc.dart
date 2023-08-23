import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils/core.dart';
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

class LocaleChangedEvent extends GlobalEvent {
  final Locale? locale;
  LocaleChangedEvent(this.locale);
}

class InitEvent extends GlobalEvent {
  InitEvent([this.onReady]);

  final ResultCallback? onReady;
}

class StateChangedEvent extends GlobalEvent {
  StateChangedEvent(this.state);

  final GlobalState state;
}

class UserAuthEvent extends GlobalEvent {
  UserAuthEvent(this.authed);

  final bool authed;
}

class UserLoginEvent extends GlobalEvent {
  UserLoginEvent(this.token);

  final TokenModel token;
}

class UserQuitEvent extends GlobalEvent {}

class GlobalState {
  GlobalState({
    UserModel? user,
    TokenModel? token,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.isAuthed = false,
  })  : user = user ?? UserModel(),
        token = token ?? TokenModel();

  final UserModel user;
  final TokenModel token;
  final ThemeMode themeMode;
  final Locale? locale;
  final bool isAuthed;

  GlobalState clone({
    Optional<UserModel>? user,
    Optional<TokenModel>? token,
    ThemeMode? themeMode,
    Optional<Locale>? locale,
    bool? isAuthed,
  }) {
    return GlobalState(
      user: user == null ? this.user : user.value,
      token: token == null ? this.token : token.value,
      themeMode: themeMode ?? this.themeMode,
      locale: locale == null ? this.locale : locale.value,
      isAuthed: isAuthed ?? this.isAuthed,
    );
  }
}

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc(StoreService storeService)
      : super(
          GlobalState(
            token: storeService.token(),
            themeMode: storeService.themeMode(),
            locale: storeService.locale(),
          ),
        ) {
    on<ThemeModeChangedEvent>((event, emit) {
      emit(state.clone(themeMode: event.themeMode));
    });

    on<LocaleChangedEvent>((event, emit) {
      emit(state.clone(locale: Optional(event.locale)));
    });

    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });

    on<InitEvent>((event, emit) {
      _init(event.onReady);
    });

    on<UserAuthEvent>((event, emit) {
      if (event.authed) {
        emit(state.clone(isAuthed: true));
      } else {
        emit(state.clone(user: Optional(UserModel())));
      }
    });

    on<UserLoginEvent>((event, emit) {
      ApiService.getInstance().addToken(event.token.accessToken);
      emit(state.clone(token: Optional(event.token)));
    });

    on<UserQuitEvent>((event, emit) {
      ApiService.getInstance().removeToken();
      emit(state.clone(user: Optional(UserModel())));
    });

    if (state.token.isValid) {
      ApiService.getInstance().addToken(state.token.accessToken);
      _upUserinfo();
    }
  }
  Future<void> _init([ResultCallback? onReady]) async {
    if (state.token.isValid) {
      ApiService.getInstance().addToken(state.token.accessToken);
      await _upUserinfo(() {});
    }
    onReady?.call(true, null);
  }

  Future<void> _upUserinfo([VoidCallback? onRequireLogin]) async {
    final result = await Api.getUserinfo(onRequireLogin);
    if (!isClosed && result.success) {
      add(
        StateChangedEvent(
          state.clone(user: Optional(result.data!)),
        ),
      );
    }
  }
}
