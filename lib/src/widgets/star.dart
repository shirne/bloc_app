import 'package:flutter/material.dart';

const _kActiveColor = Color(0xFFFDD547);
const _kNormalColor = Color(0xFFDBE0EF);

class StarWidget extends StatefulWidget {
  const StarWidget({
    super.key,
    this.size = 24,
    double? spacing,
    this.rate = 0,
    this.count = 5,
    this.isHalf = false,
    this.onChanged,
  }) : spacing = spacing ?? size / 2,
       assert(rate >= 0 && rate <= 5);

  final double size;
  final double rate;
  final double spacing;
  final bool isHalf;
  final int count;
  final Function(double)? onChanged;

  @override
  State<StarWidget> createState() => _StarWidgetState();
}

class _StarWidgetState extends State<StarWidget> {
  late final maxWidth =
      widget.size * widget.count + widget.spacing * (widget.count - 1);
  late double currentPos = widget.rate > 0
      ? (widget.rate * widget.size + (widget.rate.ceil() - 1) * widget.spacing)
      : 0;
  late final clipWidth = ValueNotifier(currentPos);

  double tmpPosition = 0;

  double getRate() {
    final intRate = (currentPos ~/ (widget.size + widget.spacing)).clamp(
      0,
      widget.count - 1,
    );
    final r = currentPos % (widget.size + widget.spacing);

    if (!widget.isHalf) {
      if (r > 0) {
        return intRate + 1.0;
      } else {
        return intRate.toDouble();
      }
    }
    if (r >= widget.size / 2) {
      return intRate + 1.0;
    }
    final half = (r * 2 / widget.size).round() / 2;
    clipWidth.value =
        intRate * (widget.size + widget.spacing) + widget.size * half;
    return (intRate + half).clamp(0, widget.count.toDouble());
  }

  double fixRate(double pos) {
    final intRate = (pos ~/ (widget.size + widget.spacing)).clamp(
      0,
      widget.count - 1,
    );
    final r = pos % (widget.size + widget.spacing);

    double half = 0;
    if (r >= widget.size / 2) {
      half = 1.0;
    } else if (r > 0) {
      half = widget.isHalf ? 0.5 : 1.0;
    }
    return intRate * (widget.size + widget.spacing) + half * widget.size;
  }

  @override
  Widget build(BuildContext context) {
    final stars = <Widget>[
      for (int i = 0; i < widget.count; i++) ...[
        const Icon(Icons.star_rounded),
        if (i < widget.count - 1) SizedBox(width: widget.spacing),
      ],
    ];
    final child = Stack(
      children: [
        IconTheme(
          data: IconThemeData(size: widget.size, color: _kNormalColor),
          child: Row(mainAxisSize: MainAxisSize.min, children: stars),
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
              data: IconThemeData(size: widget.size, color: _kActiveColor),
              child: Row(mainAxisSize: MainAxisSize.min, children: stars),
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
        tmpPosition = d.localPosition.dx;
        currentPos = fixRate(tmpPosition);
        clipWidth.value = currentPos;
        widget.onChanged?.call(getRate());
      },
      onPanDown: (d) {
        tmpPosition = d.localPosition.dx;
        clipWidth.value = tmpPosition.clamp(0, maxWidth);
      },
      onPanUpdate: (d) {
        tmpPosition = d.localPosition.dx;
        clipWidth.value = tmpPosition.clamp(0, maxWidth);
      },
      onPanEnd: (d) {
        currentPos = fixRate(tmpPosition);
        clipWidth.value = currentPos;
        widget.onChanged?.call(getRate());
      },
      onPanCancel: () {
        clipWidth.value = currentPos;
      },
      child: child,
    );
  }
}
