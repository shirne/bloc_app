import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

class CustomRefresh extends StatefulWidget {
  CustomRefresh({
    super.key,
    ScrollController? controller,
    required this.onRefresh,
    this.onLoadMore,
    this.isHasMore,
    this.loadingMoreBuilder,
    this.maxDistance = 50,
    required this.slivers,
  }) : controller = controller ?? ScrollController();

  final ScrollController controller;
  final FutureOr<void> Function() onRefresh;
  final FutureOr<void> Function()? onLoadMore;
  final bool Function()? isHasMore;
  final Widget Function(BuildContext, bool)? loadingMoreBuilder;
  final double maxDistance;
  final List<Widget> slivers;

  @override
  State<CustomRefresh> createState() => _CustomRefreshState();
}

class _CustomRefreshState extends State<CustomRefresh> {
  final isRefreshing = ValueNotifier(false);
  final isLoadingMore = ValueNotifier(false);
  bool isLoadingError = false;

  void loadMore() async {
    isLoadingMore.value = true;
    try {
      await widget.onLoadMore?.call();
    } catch (e) {
      logger.warning(e);
      isLoadingError = true;
    } finally {
      isLoadingMore.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          controller: widget.controller,
          slivers: [
            SliverToBoxAdapter(
              child: ValueListenableBuilder(
                valueListenable: isRefreshing,
                builder: (context, value, child) {
                  return SizedBox(
                    height: value ? widget.maxDistance : 0,
                  );
                },
              ),
            ),
            ...widget.slivers,
            if (widget.onLoadMore != null)
              SliverToBoxAdapter(
                child: ValueListenableBuilder(
                  valueListenable: isLoadingMore,
                  builder: (context, isLoadmore, child) {
                    final loadmoreWidget =
                        widget.loadingMoreBuilder?.call(context, isLoadmore);
                    if (widget.isHasMore?.call() == false) {
                      return loadmoreWidget ?? Center(child: Text('No More'));
                    }
                    if (!isLoadmore) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        loadMore();
                      });
                    }
                    if (loadmoreWidget != null) {
                      return loadmoreWidget;
                    }
                    if (isLoadmore) {
                      return Center(child: CupertinoActivityIndicator());
                    }
                    return SizedBox.shrink();
                  },
                ),
              )
          ],
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: CustomRefreshIndicator(
            widget.controller,
            maxDistance: widget.maxDistance,
            onRefresh: () async {
              isRefreshing.value = true;
              try {
                await widget.onRefresh.call();
              } catch (e) {
                logger.warning(e);
              } finally {
                isRefreshing.value = false;
              }
            },
          ),
        ),
      ],
    );
  }
}

class CustomRefreshIndicator extends StatefulWidget {
  const CustomRefreshIndicator(
    this.controller, {
    super.key,
    required this.onRefresh,
    this.maxDistance = 50,
  });

  final ScrollController controller;

  final FutureOr<void> Function() onRefresh;

  final double maxDistance;

  @override
  State<CustomRefreshIndicator> createState() => _CustomRefreshIndicatorState();
}

class _CustomRefreshIndicatorState extends State<CustomRefreshIndicator> {
  double scrollHeight = 0;
  bool isRefreshing = false;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant CustomRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);

      updatePosition();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    updatePosition();
  }

  void updatePosition() {
    if (isRefreshing) return;
    var newHeight = (-widget.controller.offset).clamp(0.0, widget.maxDistance);

    if (newHeight != scrollHeight) {
      setState(() {
        scrollHeight = newHeight;
      });
      if (scrollHeight >= widget.maxDistance) {
        callLoading();
      }
    }
  }

  void callLoading() async {
    if (isRefreshing) return;
    setState(() {
      isRefreshing = true;
    });
    print('start loading $scrollHeight');
    try {
      await widget.onRefresh.call();
    } catch (e) {
      print('$e');
    } finally {
      print('end loading $scrollHeight');
      setState(() {
        isRefreshing = false;
        scrollHeight = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: scrollHeight,
      alignment: Alignment.center,
      child: scrollHeight > 0
          ? isRefreshing
              ? const CupertinoActivityIndicator()
              : Opacity(
                  opacity: scrollHeight / widget.maxDistance,
                  child: const Icon(Icons.arrow_downward),
                )
          : const SizedBox.shrink(),
    );
  }
}
