import 'package:flutter/widgets.dart';

import '../../common.dart';

part 'event.dart';
part 'state.dart';

class MainBloc extends CachedBloc<MainEvent, MainState> {
  MainBloc([String globalKey = '']) : super(() => MainState(), globalKey) {
    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });

    on<RefreshEvent>((event, emit) {
      emit(state.clone(status: Status.loading));
    });
  }
}
