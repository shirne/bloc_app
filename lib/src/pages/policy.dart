import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../common.dart';

class PolicyPage extends StatefulWidget {
  PolicyPage(Json? args, {super.key})
      : name = args?['name'] ?? '',
        title = args?['title'];

  final String name;
  final String? title;

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  String html = '';

  @override
  void initState() {
    super.initState();
    loadHtml();
  }

  void loadHtml() async {
    final assets = 'assets/json/${widget.name}.html';
    final content = await rootBundle.loadString(assets);
    setState(() {
      html = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? '')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: HtmlWidget(html),
      ),
    );
  }
}
