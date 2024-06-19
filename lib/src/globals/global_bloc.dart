import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../l10n/gen/l10n.dart';
import '../models/user.dart';
import '../utils/core.dart';
import 'api_service.dart';
import 'routes.dart';
import 'store_service.dart';

AppLocalizations get globalL10n => GlobalBloc.l10n;

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

class GlobalState {
  GlobalState({
    this.themeMode = ThemeMode.system,
    this.locale,
  });

  final ThemeMode themeMode;
  final Locale? locale;

  Locale? get currentLocale => locale ?? navigatorKey.currentContext?.locale;

  GlobalState clone({
    ThemeMode? themeMode,
    Optional<Locale>? locale,
  }) {
    return GlobalState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale == null ? this.locale : locale.value,
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
      _l10n = null;
      emit(state.clone(locale: Optional(event.locale)));
    });

    on<StateChangedEvent>((event, emit) {
      if (state.locale != event.state.locale) {
        _l10n = null;
      }
      emit(event.state);
    });

    on<InitEvent>((event, emit) {
      _init(event.onReady);
    });
  }

  static GlobalBloc? _instance;
  static GlobalBloc get instance => _instance!;
  String? get langTag => state.currentLocale?.toLanguageTag();

  AppLocalizations? _l10n;
  static AppLocalizations get l10n =>
      instance._l10n ??= AppLocalizations.of(navigatorKey.currentContext!)!;

  Future<void> setToken(TokenModel? token) async {
    if (token != null && token.isValid) {
      ApiService.instance.addToken(token.accessToken.toString());
      await storeService.updateToken(token);
    } else {
      ApiService.instance.removeToken();
      await storeService.deleteToken();
    }
  }

  Future<void> _init([ResultCallback? onReady]) async {
    onReady?.call(true, null);
  }
}
