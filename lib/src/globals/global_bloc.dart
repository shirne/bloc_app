import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';

abstract class GlobalEvent {}

class UserAuthEvent extends GlobalEvent {}

class UserLoginEvent extends GlobalEvent {}

class UserQuitEvent extends GlobalEvent {}

class GlobalState {
  final User? user;
  final ThemeMode themeMode;
  GlobalState({this.user, this.themeMode = ThemeMode.system});
}

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc(GlobalState initialState) : super(initialState);
}
