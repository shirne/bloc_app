import 'package:flutter/material.dart';

mixin TabPageState<T extends StatefulWidget> on State<T> {
  bool isActived = true;

  TabController? tabController;

  @mustCallSuper
  void onStateChange(bool newState) {
    setState(() {
      isActived = newState;
    });
  }

  @override
  void dispose() {
    tabController?.removeListener(_onTabChange);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (tabController != null) {
      tabController!.removeListener(_onTabChange);
    }
    tabController = DefaultTabController.of(context);
    tabController?.addListener(_onTabChange);
  }

  void _onTabChange() {
    final index = tabController!.index;
    final key = context
        .findAncestorWidgetOfExactType<TabBarView>()
        ?.children[index]
        .key;
    if (key == widget.key) {
      if (!isActived) {
        onStateChange(true);
      }
    } else {
      if (isActived) {
        onStateChange(false);
      }
    }
  }
}
