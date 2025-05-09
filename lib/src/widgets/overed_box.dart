import 'package:flutter/material.dart';

class OveredBox extends StatelessWidget {
  const OveredBox({
    super.key,
    required this.size,
    required this.overSize,
    required this.child,
    this.margin,
    this.alignment = Alignment.center,
  });

  final Size size;
  final Size overSize;
  final EdgeInsetsGeometry? margin;
  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: size.width,
      height: size.height,
      child: OverflowBox(
        maxWidth: overSize.width,
        maxHeight: overSize.height,
        alignment: alignment,
        child: child,
      ),
    );
  }
}
