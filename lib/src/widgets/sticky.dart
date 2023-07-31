import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class StickyObserver extends StatefulWidget {
  const StickyObserver({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
  });

  final Widget child;
  final Axis axis;

  static StickyObserverState? of(BuildContext context) {
    return context.findAncestorStateOfType<StickyObserverState>();
  }

  @override
  State<StickyObserver> createState() => StickyObserverState();
}

class StickyObserverState extends State<StickyObserver> {
  final scrollListener = ValueNotifier<ScrollMetrics?>(null);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.axis == widget.axis) {
          scrollListener.value = notification.metrics;
        }
        return false;
      },
      child: widget.child,
    );
  }
}

class StickyWidget extends StatefulWidget {
  const StickyWidget({super.key, required this.child, required this.offset});

  final Widget child;

  final double offset;

  @override
  State<StickyWidget> createState() => _StickyWidgetState();
}

class _StickyWidgetState extends State<StickyWidget> {
  ValueNotifier<ScrollMetrics?>? scrollListener;
  StickyObserverState? state;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scrollListener?.removeListener(checkPosition);
    state = StickyObserver.of(context);
    scrollListener = state?.scrollListener;
    scrollListener?.addListener(checkPosition);
  }

  @override
  void dispose() {
    scrollListener?.removeListener(checkPosition);
    super.dispose();
  }

  void checkPosition() {
    if (state == null) return;
    if (!context.mounted) {
      showOverlay();
      return;
    }
    final offset = (context
            .findAncestorRenderObjectOfType<RenderSliverToBoxAdapter>()
            ?.parentData as SliverPhysicalParentData?)
        ?.paintOffset;
    final offsetAxis =
        (state?.widget.axis == Axis.horizontal ? offset?.dx : offset?.dy) ?? 0;
    if (offsetAxis < widget.offset) {
      showOverlay();
    } else {
      hideOverlay();
    }
  }

  OverlayEntry? overlay;

  void showOverlay() {
    if (overlay == null) {
      overlay = OverlayEntry(
        builder: (context) {
          return Flex(
            direction: state?.widget.axis ?? Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: state?.widget.axis == Axis.horizontal
                    ? EdgeInsets.only(left: widget.offset)
                    : EdgeInsets.only(top: widget.offset),
                child: Material(child: widget.child),
              ),
            ],
          );
        },
      );
      Overlay.of(context).insert(overlay!);
    }
  }

  void hideOverlay() {
    overlay?.remove();
    overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
