import 'package:flutter/material.dart';

import '../utils/core.dart';

class AvatarWidget extends StatelessWidget {
  const AvatarWidget(
    this.avator, {
    super.key,
    this.onTap,
    this.size = 60,
  });

  final String avator;

  final double size;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = avator.isEmpty
        ? DefaultAvatar(size)
        : CircleAvatar(
            radius: size / 2,
            backgroundColor: context.colorScheme.outlineVariant,
            backgroundImage: NetworkImage(avator),
          );
    return onTap == null
        ? child
        : GestureDetector(
            onTap: onTap,
            child: child,
          );
  }
}

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
