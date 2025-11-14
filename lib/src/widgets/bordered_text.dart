import 'package:flutter/material.dart';

class BorderedText extends StatelessWidget {
  const BorderedText(
    this.text, {
    super.key,
    this.style = const TextStyle(),
    required this.borderColor,
    this.borderWidth = 2,
  });

  final String text;
  final TextStyle style;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = borderWidth + 1
              ..color = borderColor,
          ),
        ),
        Text(text, style: style),
      ],
    );
  }
}
