import 'package:flutter/material.dart';

import '../utils/core.dart';

class DefaultAvatar extends StatelessWidget {
  const DefaultAvatar(this.size, {super.key, this.radius});

  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colorScheme.outlineVariant,
        shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: radius == null ? null : BorderRadius.circular(radius!),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: size / 1.6,
        color: context.colorScheme.tertiary,
      ),
    );
  }
}
