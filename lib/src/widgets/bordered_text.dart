import 'package:flutter/material.dart';

class BorderedText extends StatelessWidget {
  const BorderedText({
    super.key,
    required this.text,
    this.borderColor,
    this.borderGradient,
    this.borderWidth = 2,
    this.strokeCap,
    this.strokeJoin,
  }) : assert(borderColor != null || borderGradient != null);

  BorderedText.text(
    String text, {
    super.key,
    TextStyle? style,
    this.borderColor,
    this.borderGradient,
    this.borderWidth = 2,
    this.strokeCap,
    this.strokeJoin,
  }) : assert(borderColor != null || borderGradient != null),
       text = Text(text, style: style);

  final Text text;
  final Color? borderColor;
  final Gradient? borderGradient;
  final double borderWidth;
  final StrokeCap? strokeCap;
  final StrokeJoin? strokeJoin;

  @override
  Widget build(BuildContext context) {
    Widget bgText = Text(
      text.data ?? '',
      strutStyle: text.strutStyle,
      textAlign: text.textAlign,
      textDirection: text.textDirection,
      locale: text.locale,
      softWrap: text.softWrap,
      overflow: text.overflow,
      textScaler: text.textScaler,
      maxLines: text.maxLines,
      //semanticsLabel: text.semanticsLabel,
      //semanticsIdentifier: text.semanticsIdentifier,
      textWidthBasis: text.textWidthBasis,
      textHeightBehavior: text.textHeightBehavior,
      //selectionColor: text.selectionColor,
      style: (text.style ?? TextStyle()).copyWith(
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth + 1
          ..strokeCap = strokeCap ?? StrokeCap.round
          ..strokeJoin = strokeJoin ?? StrokeJoin.round
          ..color = borderColor ?? Colors.black,
      ),
    );
    if (borderGradient != null) {
      bgText = ShaderMask(
        shaderCallback: (bounds) {
          return borderGradient!.createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: bgText,
      );
    }
    return Stack(
      children: [
        IgnorePointer(ignoring: true, child: bgText),
        text,
      ],
    );
  }
}
