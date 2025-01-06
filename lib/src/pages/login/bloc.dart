import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import '../../common.dart';
import '../../models/user.dart';

part 'event.dart';
part 'state.dart';

class LoginBloc extends CachedBloc<LoginEvent, LoginState> {
  LoginBloc([String globalKey = '']) : super(() => LoginState(), globalKey) {
    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });

    on<RefreshEvent>((event, emit) {
      emit(state.clone(status: Status.loading));
    });
    on<SubmitEvent>(_submit);
  }

  FutureOr<void> _submit(SubmitEvent event, Emitter<LoginState> emit) async {
    emit(state.clone(status: Status.loading));
    await Future.delayed(const Duration(milliseconds: 500));
    if (isClosed) return;
    if (UserBloc.hasInstance) {
      UserBloc.instance.add(
        UserLoginEvent(
          TokenModel(
            accessToken: 'aaa',
            refreshToken: 'bbb',
            expireIn: 1000,
            createTime: DateTime.now(),
          ),
        ),
      );
    }
  }
}
