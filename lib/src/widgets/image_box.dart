import 'package:flutter/material.dart';

import '../utils/core.dart';

class ImageBox extends StatelessWidget {
  const ImageBox({
    super.key,
    required this.image,
    this.width,
    double? height,
    this.radius = 8,
    this.margin,
    this.borderRadius,
    this.fit,
  }) : height = height ?? width;

  final ImageProvider image;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double radius;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: context.colorScheme.outlineVariant,
        borderRadius: borderRadius ?? BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return FractionallySizedBox(
            widthFactor: 0.5,
            heightFactor: 0.5,
            child: FittedBox(
              child: Icon(
                Icons.image,
                color: context.colorScheme.tertiary,
              ),
            ),
          );
        },
      ),
    );
  }
}
