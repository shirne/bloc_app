import 'package:flutter/widgets.dart';

import '../utils/core.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    this.icon,
    required this.label,
  });

  final Widget? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(
        color: context.colorScheme.tertiary,
        size: 120,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) icon!,
          Text(
            label,
            style: context.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
