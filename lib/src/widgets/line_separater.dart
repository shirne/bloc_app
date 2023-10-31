import 'package:flutter/material.dart';

import '../common.dart';

class Line extends StatelessWidget {
  const Line({
    super.key,
    this.thickness = 0.5,
    this.margin,
    this.color,
  });

  final double thickness;

  final EdgeInsetsGeometry? margin;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 0,
      child: OverflowBox(
        maxHeight: thickness,
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: margin,
          height: thickness,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: color ??
                    context.theme.dividerTheme.color ??
                    context.theme.dividerColor,
                width: thickness,
                // strokeAlign: BorderSide.strokeAlignCenter,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VerticalLine extends StatelessWidget {
  const VerticalLine({
    super.key,
    this.thickness = 0.5,
    this.margin,
    this.color,
  });

  final double thickness;

  final EdgeInsetsGeometry? margin;

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0,
      child: OverflowBox(
        maxWidth: thickness,
        alignment: Alignment.centerRight,
        child: Container(
          margin: margin,
          width: thickness,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: color ??
                    context.theme.dividerTheme.color ??
                    context.theme.dividerColor,
                width: thickness,
                // strokeAlign: BorderSide.strokeAlignCenter,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
