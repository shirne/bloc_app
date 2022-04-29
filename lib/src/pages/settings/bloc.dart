import 'package:flutter/widgets.dart';

import '../../widgets/cached_bloc.dart';

part 'event.dart';
part 'state.dart';

class SettingsBloc extends CachedBloc<SettingsEvent, SettingsState> {
  SettingsBloc([String globalKey = ''])
      : super(() => SettingsState(), globalKey) {
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
