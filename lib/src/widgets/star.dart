import 'package:flutter/material.dart';

const _kActiveColor = Color(0xFFFDD547);
const _kNormalColor = Color(0xFFDBE0EF);

class StarWidget extends StatefulWidget {
  const StarWidget({
    super.key,
    this.size = 24,
    double? spacing,
    this.rate = 0,
    this.onChanged,
  })  : spacing = spacing ?? size / 2,
        assert(rate >= 0 && rate <= 5);

  final double size;
  final double rate;
  final double spacing;
  final Function(double)? onChanged;

  @override
  State<StarWidget> createState() => _StarWidgetState();
}

class _StarWidgetState extends State<StarWidget> {
  late double currentPos = widget.rate > 0
      ? (widget.rate * widget.size + (widget.rate.ceil() - 1) * widget.spacing)
      : 0;
  late final clipWidth = ValueNotifier(currentPos);

  double tmpPosition = 0;

  double getRate() {
    final intRate = currentPos ~/ (widget.size + widget.spacing);
    final r = currentPos % (widget.size + widget.spacing);
    if (r > widget.size) {
      return intRate + 1.0;
    }
    final half = (r * 2 / widget.size).round() / 2;
    clipWidth.value =
        intRate * (widget.size + widget.spacing) + widget.size * half;
    return intRate + half;
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      children: [
        IconTheme(
          data: IconThemeData(
            size: widget.size,
            color: _kNormalColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded),
              SizedBox(width: widget.spacing),
              const Icon(Icons.star_rounded),
              SizedBox(width: widget.spacing),
              const Icon(Icons.star_rounded),
              SizedBox(width: widget.spacing),
              const Icon(Icons.star_rounded),
              SizedBox(width: widget.spacing),
              const Icon(Icons.star_rounded),
            ],
          ),
        ),
        ValueListenableBuilder(
          valueListenable: clipWidth,
          builder: (context, value, child) {
            return Container(
              width: value,
              height: widget.size,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(),
              child: child,
            );
          },
          child: OverflowBox(
            maxWidth: MediaQuery.of(context).size.width,
            alignment: Alignment.centerLeft,
            child: IconTheme(
              data: IconThemeData(
                size: widget.size,
                color: _kActiveColor,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded),
                  SizedBox(width: widget.spacing),
                  const Icon(Icons.star_rounded),
                  SizedBox(width: widget.spacing),
                  const Icon(Icons.star_rounded),
                  SizedBox(width: widget.spacing),
                  const Icon(Icons.star_rounded),
                  SizedBox(width: widget.spacing),
                  const Icon(Icons.star_rounded),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    if (widget.onChanged == null) {
      return child;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) {
        currentPos = tmpPosition = d.localPosition.dx;
        widget.onChanged?.call(getRate());
      },
      onPanDown: (d) {
        tmpPosition = d.localPosition.dx;
        clipWidth.value = tmpPosition;
      },
      onPanUpdate: (d) {
        tmpPosition = d.localPosition.dx;
        clipWidth.value = tmpPosition;
      },
      onPanEnd: (d) {
        currentPos = tmpPosition;
        widget.onChanged?.call(getRate());
      },
      onPanCancel: () {
        clipWidth.value = currentPos;
      },
      child: child,
    );
  }
}
