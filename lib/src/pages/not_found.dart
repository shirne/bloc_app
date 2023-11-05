import 'package:flutter/material.dart';

class NotFoundPage extends StatelessWidget {
  final String? pageName;
  const NotFoundPage(this.pageName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text("Page $pageName not found")),
    );
  }
}
