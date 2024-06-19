import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../utils/core.dart';
import '../widgets/cached_bloc.dart';
import 'api.dart';
import 'api_service.dart';
import 'store_service.dart';

final _noticeBadge = ValueNotifier(0);
final _tokenNotifier = ValueNotifier(TokenModel.empty);

@immutable
abstract class UserEvent {}

class InitEvent extends UserEvent {
  InitEvent([this.onReady]);

  final ResultCallback? onReady;
}

class StateChangedEvent extends UserEvent {
  StateChangedEvent(this.state);

  final UserState state;
}

class UpdateUserEvent extends UserEvent {}

class UserAuthEvent extends UserEvent {
  UserAuthEvent(this.authed);

  final bool authed;
}

class UserLoginEvent extends UserEvent {
  UserLoginEvent(this.token);

  final TokenModel token;
}

class TokenRefreshEvent extends UserEvent {
  TokenRefreshEvent(this.token);

  final TokenModel token;
}

class UserQuitEvent extends UserEvent {}

class UpdateNoticeBadgeEvent extends UserEvent {}

class UserState {
  UserState({
    UserModel? user,
    this.isAuthed = false,
  }) : user = user ?? UserModel.empty;

  final UserModel user;

  final bool isAuthed;

  ValueNotifier<int> get noticeBadge => _noticeBadge;
  // ValueNotifier<ConnectState> get chatConnectState => _chatStateNotifier;

  TokenModel get token => _tokenNotifier.value;
  set token(TokenModel? token) =>
      _tokenNotifier.value = token ?? TokenModel.empty;

  UserState clone({
    Optional<UserModel>? user,
    bool? isAuthed,
  }) {
    return UserState(
      user: user == null ? this.user : user.value,
      isAuthed: isAuthed ?? this.isAuthed,
    );
  }
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final StoreService storeService;
  UserBloc(this.storeService)
      : super(
          UserState(),
        ) {
    _instance = this;

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

      await upUserinfo(() {});
    });

    on<TokenRefreshEvent>((event, emit) async {
      state.token = event.token;
    });

    on<UserQuitEvent>((event, emit) {
      state.token = null;
      CachedBloc.clearCache();
      emit(state.clone(user: Optional(null)));
    });

    on<UpdateNoticeBadgeEvent>((event, emit) {
      updateBadge();
    });

    _tokenNotifier.addListener(_onTokenChange);

    state.token = storeService.token;

    ApiService.instance.onRequest = _checkToken;
  }

  static UserBloc? _instance;
  static UserBloc get instance => _instance!;

  @override
  Future<void> close() {
    _tokenNotifier.removeListener(_onTokenChange);
    return super.close();
  }

  Future<void> _checkToken() async {
    if (state.token.isValid) {
      if (state.token.isExpire) {
        ApiService.instance.onRequest = null;
        final result = await Api.ucenter.doRefresh(
          state.token.refreshToken,
        );
        if (result.success && result.data != null) {
          add(TokenRefreshEvent(result.data!));
        } else {
          add(UserQuitEvent());
        }
        ApiService.instance.onRequest = _checkToken;
      }
    }
  }

  void _onTokenChange() {
    setToken(state.token);
  }

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
    if (state.token.isValid) {
      await Future.wait([
        upUserinfo(() {}),
      ]);
    }
    onReady?.call(true, null);
  }

  Future<void> upUserinfo([
    VoidCallback? onRequireLogin,
    bool isComplete = false,
  ]) async {
    final result = await Api.ucenter.getUserinfo(onRequireLogin);
    if (!isClosed && result.success) {
      add(
        StateChangedEvent(state.clone(user: Optional(result.data))),
      );
    }
  }

  Future<void> updateBadge([VoidCallback? onRequireLogin]) async {
    final result = await Api.ucenter.getNoticeCount(
      onRequireLogin,
    );
    if (result.success) {
      _noticeBadge.value = result.data?['unread_count'] ?? 0;
    }
  }
}

extension BaseStateExt on BaseState {
  UserModel get user => UserBloc.instance.state.user;
  TokenModel get token => UserBloc.instance.state.token;
}
