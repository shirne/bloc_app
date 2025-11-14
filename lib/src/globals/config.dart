import 'package:flutter/foundation.dart';

import '../utils/core.dart';

enum Env {
  prod,
  test,
  dev;

  static Env fromName(String name) {
    return values.firstWhereOrNull((n) => n.name == name) ?? Env.dev;
  }
}

const envName = String.fromEnvironment('env');

class Config {
  Config._();

  static final shareRegexp = RegExp(r'https?://[a-z0-9\-\.]+\.shirne\.com/');

  static final env = kReleaseMode ? Env.prod : Env.fromName(envName);

  static const serverUrl = ['https://www.shirne.com/api/'];

  static const imgServer = '';
}
