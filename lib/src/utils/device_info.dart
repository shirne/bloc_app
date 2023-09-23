import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfo {
  static DeviceInfo? _instance;
  factory DeviceInfo() {
    return _instance ??= DeviceInfo._();
  }

  DeviceInfo._();

  final deviceInfo = DeviceInfoPlugin();

  late AndroidDeviceInfo androidInfo;
  late IosDeviceInfo iosInfo;
  late WebBrowserInfo webBrowserInfo;

  final bool isWeb = kIsWeb;
  bool get isAndroid => !kIsWeb && Platform.isAndroid;
  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool get isMacOS => !kIsWeb && Platform.isMacOS;
  bool get isWindows => !kIsWeb && Platform.isWindows;
  bool get isLinux => !kIsWeb && Platform.isLinux;

  bool get lowerAndroidQ => isAndroid && androidInfo.version.sdkInt < 29;

  Future<void> init() async {
    if (isWeb) {
      webBrowserInfo = await deviceInfo.webBrowserInfo;
    } else if (isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    } else if (isIOS) {
      iosInfo = await deviceInfo.iosInfo;
    }
  }
}
