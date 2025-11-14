import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  const Gap({super.key, this.width, this.height});

  const Gap.v(double height, {Key? key}) : this(key: key, height: height);

  const Gap.h(double width, {Key? key}) : this(key: key, width: width);

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}
