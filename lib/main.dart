import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/globals/store_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storeService = await StoreService.getInstance();
  runApp(MainApp(storeService));
}
