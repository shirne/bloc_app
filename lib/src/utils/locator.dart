import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../globals/localizations.dart';
import 'utils.dart';

class LocatorUtil {
  LocatorUtil._();

  static LocatorUtil? _instance;
  factory LocatorUtil() {
    return _instance ??= LocatorUtil._().._init();
  }

  final _geolocatorPlatform = GeolocatorPlatform.instance;
  Position? current;
  Completer<Position>? _updated;
  final _initCompleter = Completer();

  Future<void> init() {
    return _initCompleter.future;
  }

  Future<void> _init() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return;

    /// 动态申请定位权限
    if (!await requestLocationPermission()) {
      MyDialog.toast(globalL10n.locationRequestFail);
      return;
    }

    await _getCurrentPosition();

    _initCompleter.complete(true);
  }

  /// 申请定位权限
  /// 授予定位权限返回true， 否则返回false
  Future<bool> requestLocationPermission() async {
    //获取当前的权限
    var status = await Permission.locationWhenInUse.status;
    if (status == PermissionStatus.granted) {
      //已经授权
      return true;
    } else {
      //未授权则发起一次申请
      status = await Permission.locationWhenInUse.request();
      if (status == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    }
  }

  Future<Position> updateLocation() {
    _getCurrentPosition();
    return _updated!.future;
  }

  Future<void> _getCurrentPosition() async {
    if (_updated != null && !_updated!.isCompleted) return;
    _updated = Completer();
    try {
      final position = await _geolocatorPlatform.getCurrentPosition();
      logger.info(position);
      _updated!.complete(position);
    } catch (e) {
      logger.warning(e);
      if (!_updated!.isCompleted) {
        _updated!.completeError(e);
      }
    }
  }
}
