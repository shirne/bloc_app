import 'package:flutter/widgets.dart';

import '../../widgets/cached_bloc.dart';

part 'event.dart';
part 'state.dart';

class LoginBloc extends CachedBloc<LoginEvent, LoginState> {
  LoginBloc([String globalKey = '']) : super(() => LoginState(), globalKey) {
    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });

    on<RefreshEvent>((event, emit) {
      emit(state.clone(status: Status.loading));
      _loadData(onError: event.onError);
    });

    _loadData();
  }

  _loadData({void Function(String message)? onError}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    //TODO load data
  }
}
