import 'dart:async';

import 'package:flutter/cupertino.dart';

class StateButtonWrapper extends StatefulWidget {
  const StateButtonWrapper(
    this.builder, {
    super.key,
    this.onPressed,
    this.child,
    this.loadingRadius = 10,
  });

  final FutureOr<void> Function()? onPressed;
  final Widget Function(
    BuildContext context,
    WidgetStatesController controller,
    VoidCallback? onPressed,
    Widget? child,
  ) builder;
  final Widget? child;
  final double loadingRadius;

  @override
  State<StateButtonWrapper> createState() => _StateButtonWrapperState();
}

class _StateButtonWrapperState extends State<StateButtonWrapper> {
  final controller = WidgetStatesController();

  void onPressed() async {
    if (controller.value.contains(WidgetState.disabled)) return;
    controller.update(WidgetState.disabled, true);
    await widget.onPressed?.call();
    controller.update(WidgetState.disabled, false);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(
      context,
      controller,
      widget.onPressed == null ? null : onPressed,
      widget.onPressed == null
          ? widget.child
          : ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (value.contains(WidgetState.disabled)) ...[
                      CupertinoActivityIndicator(radius: widget.loadingRadius),
                      const SizedBox(width: 4),
                    ],
                    if (child != null) child,
                  ],
                );
              },
              child: widget.child,
            ),
    );
  }
}
