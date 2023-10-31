import 'package:flutter/material.dart';

import '../utils/core.dart';
import '../widgets/default_avatar.dart';

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
