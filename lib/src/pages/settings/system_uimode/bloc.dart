import 'package:flutter/widgets.dart';

import '../../../common.dart';

part 'event.dart';
part 'state.dart';

class SystemUIModeBloc
    extends CachedBloc<SystemUIModeEvent, SystemUIModeState> {
  SystemUIModeBloc([String globalKey = ''])
      : super(() => SystemUIModeState(), globalKey) {
    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });

    on<RefreshEvent>((event, emit) {
      emit(state.clone(status: Status.loading));
      _loadData(onError: event.onError);
    });

    _loadData();
  }

  void updateContrastEnforced(bool b) {
    add(StateChangedEvent(state.clone(contrastEnforced: b)));
  }

  Future<void> _loadData({void Function(String message)? onError}) async {}
}
