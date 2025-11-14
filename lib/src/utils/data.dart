import 'dart:async';
import 'dart:io';
import 'package:isar_community/isar.dart';

import '../models/repositories.dart';
import 'utils.dart';

class DataUtil {
  DataUtil._();

  static Future<void> init() async {}

  static Isar? _box;
  static const _myIsar = 'my_isar';
  static Completer<bool>? _isOpening;

  static Isar get box => _box!;
  static bool get isOpened => _box != null && _box!.isOpen;

  /// open another box
  static Future<Isar> openBox<V>() async {
    if (_box != null) {
      if (_box!.isOpen) {
        return _box!;
      }

      _box = null;
    }
    if (_isOpening != null) {
      await _isOpening!.future;
      return openBox();
    }
    _isOpening = Completer();
    _box ??= await Isar.open(
      [UserProfileSchema],
      name: _myIsar,
      directory: await Utils.getDocDir(name: 'isardata'),
    );
    if (_isOpening?.isCompleted == false) {
      _isOpening?.complete(true);
      _isOpening = null;
    }
    return _box!;
  }

  static String get name => box.name;

  static void close() {
    box.close();
  }

  static Future<void> clear() async {
    if (isOpened) {
      await box.clear();
    }
  }

  static Future<void> deleteFromDisk() async {
    if (isOpened) {
      await Directory(box.directory!).delete(recursive: true);
    }
  }
}
