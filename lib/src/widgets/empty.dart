import 'package:flutter/material.dart';

import '../utils/core.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, this.icon, required this.label});

  final Widget? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: context.colorScheme.outlineVariant, size: 120),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon ?? const Icon(Icons.list_alt_rounded),
            Text(label, style: context.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class EmptyList extends StatelessWidget {
  const EmptyList({super.key, this.icon, required this.label});

  final Widget? icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics().applyTo(
        const BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.only(top: 100, bottom: 100),
      child: EmptyWidget(icon: icon, label: label),
    );
  }
}
