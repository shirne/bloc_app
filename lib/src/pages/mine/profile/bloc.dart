import 'package:flutter/widgets.dart';

import '../../../common.dart';

part 'event.dart';
part 'state.dart';

class ProfileBloc extends CachedBloc<ProfileEvent, ProfileState> {
  ProfileBloc([String globalKey = '']) : super(() => ProfileState(), globalKey) {
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
    add(StateChangedEvent(ProfileState(status: Status.loading)));
    await Future.delayed(const Duration(milliseconds: 500));
    //TODO load data
    if(isClosed){
      return;
    }
    add(StateChangedEvent(ProfileState(status: Status.success)));
  }
}
