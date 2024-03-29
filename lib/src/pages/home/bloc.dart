import 'package:flutter/widgets.dart';

import '../../widgets/cached_bloc.dart';

part 'event.dart';
part 'state.dart';

class HomeBloc extends CachedBloc<HomeEvent, HomeState> {
  HomeBloc([String globalKey = '']) : super(() => HomeState(), globalKey) {
    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });

    on<RefreshEvent>((event, emit) {
      emit(state.clone(status: Status.loading));
      _loadData(onError: event.onError);
    });

    on<IncreaseEvent>((event, emit) {
      emit(state.clone(count: state.count + event.increase));
    });

    _loadData();
  }

  Future<void> _loadData({void Function(String message)? onError}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (isClosed) {
      return;
    }
    add(StateChangedEvent(state.clone(status: Status.success)));
  }
}
