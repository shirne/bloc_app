import 'package:flutter/foundation.dart';

enum Env {
  production,
  development,
}

class Config {
  Config._();

  static const env = kReleaseMode ? Env.production : Env.development;

  static const serverUrl = 'https://www.shirne.com/api/';
  static const imgServer = '';
}
