import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../utils/core.dart';

class Loading extends StatefulWidget {
  const Loading(this.progress, {super.key});

  final double progress;

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with SingleTickerProviderStateMixin {
  late final animationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );
  double angle = 0.0;
  bool isStop = false;

  @override
  void initState() {
    super.initState();
    animationController.addListener(_onTicker);
    restart();
  }

  @override
  void dispose() {
    animationController
      ..removeListener(_onTicker)
      ..stop();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant Loading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress >= 1) {
      isStop = true;
    }
  }

  void restart() {
    animationController
      ..reset()
      ..forward().whenComplete(() {
        if (!isStop) {
          restart();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Icon(
        Icons.refresh,
        size: 42,
        color: context.colorScheme.onPrimaryContainer,
      ),
    );
  }

  void _onTicker() {
    if (animationController.value > 0.7) {
      setState(() {
        angle = (math.pi * (animationController.value - 0.7) / 0.29).clamp(
          0,
          math.pi,
        );
      });
    }
  }
}
