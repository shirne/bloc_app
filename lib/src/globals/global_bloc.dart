import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils/core.dart';
import 'api.dart';
import 'api_service.dart';
import 'routes.dart';
import 'store_service.dart';

typedef ResultCallback<T> = void Function(bool, T? data);

final _noticeBadge = ValueNotifier(0);
//final _chatStateNotifier = ValueNotifier(ConnectState.init);
final _tokenNotifier = ValueNotifier(TokenModel.empty);

@immutable
abstract class GlobalEvent {}

class ThemeModeChangedEvent extends GlobalEvent {
  ThemeModeChangedEvent(this.themeMode);

  final ThemeMode themeMode;
}

class LocaleChangedEvent extends GlobalEvent {
  LocaleChangedEvent(this.locale);

  final Locale? locale;
}

class InitEvent extends GlobalEvent {
  InitEvent([this.onReady]);

  final ResultCallback? onReady;
}

class StateChangedEvent extends GlobalEvent {
  StateChangedEvent(this.state);

  final GlobalState state;
}

class UpdateUserEvent extends GlobalEvent {}

class UserAuthEvent extends GlobalEvent {
  UserAuthEvent(this.authed);

  final bool authed;
}

class UserLoginEvent extends GlobalEvent {
  UserLoginEvent(this.token, {this.hasPassword = true, this.hasProfile = true});

  final TokenModel token;
  final bool hasPassword;
  final bool hasProfile;
}

class TokenRefreshEvent extends GlobalEvent {
  TokenRefreshEvent(this.token);

  final TokenModel token;
}

class UserQuitEvent extends GlobalEvent {}

class UpdateNoticeBadgeEvent extends GlobalEvent {}

class GlobalState {
  GlobalState({
    UserModel? user,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.hasPassword = true,
    this.hasProfile = true,
    this.isAuthed = false,
  }) : user = user ?? UserModel.empty;

  final UserModel user;
  final ThemeMode themeMode;
  final Locale? locale;
  final bool hasPassword;
  final bool hasProfile;
  final bool isAuthed;

  Locale? get currentLocale => locale ?? navigatorKey.currentContext?.locale;

  ValueNotifier<int> get noticeBadge => _noticeBadge;
  //ValueNotifier<ConnectState> get chatConnectState => _chatStateNotifier;

  TokenModel get token => _tokenNotifier.value;
  set token(TokenModel? token) =>
      _tokenNotifier.value = token ?? TokenModel.empty;

  GlobalState clone({
    Optional<UserModel>? user,
    ThemeMode? themeMode,
    Optional<Locale>? locale,
    bool? hasPassword,
    bool? hasProfile,
    bool? isAuthed,
  }) {
    return GlobalState(
      user: user == null ? this.user : user.value,
      themeMode: themeMode ?? this.themeMode,
      locale: locale == null ? this.locale : locale.value,
      hasPassword: hasPassword ?? true,
      hasProfile: hasProfile ?? true,
      isAuthed: isAuthed ?? this.isAuthed,
    );
  }

  String getThemeName(BuildContext context) {
    switch (themeMode) {
      case ThemeMode.light:
        return context.l10n.themeLight;
      case ThemeMode.dark:
        return context.l10n.themeDark;
      default:
        return context.l10n.themeSystem;
    }
  }
}

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  final StoreService storeService;
  GlobalBloc(this.storeService)
      : super(
          GlobalState(
            themeMode: storeService.themeMode(),
            locale: storeService.locale(),
          ),
        ) {
    _instance = this;

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
        emit(state.clone(isAuthed: event.authed));
      } else {
        state.token = null;
        emit(
          state.clone(
            user: Optional(null),
            isAuthed: false,
          ),
        );
      }
    });

    on<UpdateUserEvent>((event, emit) async {
      await upUserinfo(() {});
    });

    on<UserLoginEvent>((event, emit) async {
      state.token = event.token;
      if (!event.hasPassword || !event.hasProfile) {
        emit(state.clone(
          hasPassword: event.hasPassword,
          hasProfile: event.hasProfile,
        ));
      }
      await upUserinfo(() {});
    });

    on<TokenRefreshEvent>((event, emit) async {
      state.token = event.token;
    });

    on<UserQuitEvent>((event, emit) {
      state.token = null;
      emit(state.clone(user: Optional(null)));
    });

    _tokenNotifier.addListener(_onTokenChange);

    state.token = storeService.token();
  }

  static GlobalBloc? _instance;
  static GlobalBloc get instance => _instance!;
  String? get langTag => state.currentLocale?.toLanguageTag();

  @override
  Future<void> close() {
    _tokenNotifier.removeListener(_onTokenChange);
    return super.close();
  }

  void _onTokenChange() {
    setToken(state.token);
  }

  Future<void> setToken(TokenModel? token) async {
    if (token != null && token.isValid) {
      ApiService.getInstance().addToken(token.accessToken.toString());
      await storeService.updateToken(token);
    } else {
      ApiService.getInstance().removeToken();
      await storeService.deleteToken();
    }
  }

  Future<void> _init([ResultCallback? onReady]) async {
    if (state.token.isValid) {
      await Future.wait([
        upUserinfo(),
      ]);
    }
    onReady?.call(true, null);
  }

  Future<void> upUserinfo([VoidCallback? onRequireLogin]) async {
    final result = await Api.ucenter.getUserinfo(onRequireLogin);
    if (!isClosed && result.success) {
      add(
        StateChangedEvent(
          state.clone(user: Optional(result.data)),
        ),
      );
    }
  }
}
