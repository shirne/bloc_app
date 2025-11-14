import 'package:flutter/widgets.dart';

import '../../common.dart';

part 'event.dart';
part 'state.dart';

class ProductBloc extends CachedBloc<ProductEvent, ProductState> {
  ProductBloc([String globalKey = ''])
    : super(() => ProductState(), globalKey) {
    on<StateChangedEvent>((event, emit) {
      emit(event.state);
    });

    on<RefreshEvent>((event, emit) {
      emit(state.clone(status: Status.loading));
      _loadData(onError: event.onError);
    });

    _loadData();
  }

  Future<void> _loadData({void Function(String message)? onError}) async {
    add(StateChangedEvent(state.clone(status: Status.loading)));
    await Future.delayed(const Duration(milliseconds: 500));
    //TODO load data
    if (isClosed) {
      return;
    }
    add(StateChangedEvent(state.clone(status: Status.success)));
  }
}
