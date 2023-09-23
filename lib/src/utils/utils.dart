import 'dart:io';
import 'dart:math' as math;
import 'dart:async';
import 'dart:developer';

import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../globals/config.dart';
import 'device_info.dart';

final logger = Logger.root
  ..level = Config.env == Env.dev ? Level.ALL : Level.WARNING
  ..onRecord.listen((record) {
    log(
      record.message,
      time: record.time,
      level: record.level.value,
      error: record.error,
      stackTrace: record.stackTrace,
      sequenceNumber: record.sequenceNumber,
    );
  });

final datetimeFmt = DateFormat('yyyy-MM-dd HH:mm:ss');
final dateFmt = DateFormat('yyyy-MM-dd');
final timeFmt = DateFormat('HH:mm:ss');

class Utils {
  static final mobileExp = RegExp(r'^1[3-9][0-9]{9}$');
  static final emailExp = RegExp(r'^[\w]+@[\w]+(\.[\w]+)+$');
  static final chineseNameExp = RegExp(r'^([\xe4-\xe9][\x80-\xbf]{2}){2,4}$');
  static final usernameExp = RegExp(r'^[a-z][0-9a-z\-_]{5,}');

  static final hasLetterExp = RegExp(r'[a-zA-Z]+');
  static final hasUpperLetterExp = RegExp(r'[A-Z]+');
  static final hasLowerLetterExp = RegExp(r'[a-z]+');
  static final hasNumberExp = RegExp(r'[0-9]+');
  static final hasSpecialExp = RegExp(r'[^0-9a-zA-Z]+');

  static bool isMobile(String? mobile) =>
      mobile != null && mobileExp.hasMatch(mobile);
  static bool isEmail(String? email) =>
      email != null && emailExp.hasMatch(email);
  static bool isChineseName(String? name) =>
      name != null && chineseNameExp.hasMatch(name);
  static bool isUsername(String? name) =>
      name != null && usernameExp.hasMatch(name);

  static bool verifyPassword(
    String? password, {
    int length = 9,
    bool hasLetter = true,
    bool hasUpperLetter = false,
    bool hasLowerLetter = false,
    bool hasNumber = true,
    bool hasSpecial = false,
  }) {
    if (password == null || password.isEmpty) return false;
    if (password.length < length) return false;
    if (hasLetter && !hasLetterExp.hasMatch(password)) return false;
    if (hasUpperLetter && !hasUpperLetterExp.hasMatch(password)) return false;
    if (hasLowerLetter && !hasLowerLetterExp.hasMatch(password)) return false;
    if (hasNumber && !hasNumberExp.hasMatch(password)) return false;
    if (hasSpecial && !hasSpecialExp.hasMatch(password)) return false;

    return true;
  }

  static String parseString(dynamic val) {
    if (val == null) return '';
    if (val is String) return val;
    return val.toString();
  }

  static int parseInt(dynamic number, {int lerant = 0}) {
    return parseNumber(number, lerant: lerant.toDouble()).toInt();
  }

  static bool parseBool(dynamic val) {
    if (val == null) return false;
    if (val is bool) return val;
    if (val is int) {
      return val != 0;
    }
    String value = val.toString().toLowerCase();
    return value == '1' || value == 'true' || value == 'on';
  }

  static double parseNumber(dynamic number, {double lerant = 0.0}) {
    if (number == null) return lerant;
    String type = number.runtimeType.toString();
    if (type == 'String') {
      var result = double.tryParse(number);
      if (result != null) {
        return result;
      }
    } else if (type == 'int') {
      return number.toDouble();
    } else if (type == 'double') {
      return number;
    }

    return lerant;
  }

  static DateTime? parseDate(String? datestr) {
    if (datestr == null || datestr.isEmpty) return null;

    return DateTime.tryParse(datestr);
  }

  static Color variant(Color color, [double power = 1.2]) {
    final red = (color.red * power).round();
    final green = (color.green * power).round();
    final blue = (color.blue * power).round();
    return Color.fromARGB(
      color.alpha,
      red < 0 ? 0 : (red > 255 ? 255 : red),
      green < 0 ? 0 : (green > 255 ? 255 : green),
      blue < 0 ? 0 : (blue > 255 ? 255 : blue),
    );
  }

  static Alignment parseAlign(String align) {
    switch (align.toLowerCase()) {
      case 'left':
      case 'centerleft':
      case 'leftcenter':
        return Alignment.centerLeft;
      case 'top':
      case 'centertop':
      case 'topcenter':
        return Alignment.topCenter;
      case 'right':
      case 'centerright':
      case 'rightcenter':
        return Alignment.centerRight;
      case 'bottom':
      case 'centerbottom':
      case 'bottomcenter':
        return Alignment.bottomCenter;
      case 'topleft':
      case 'lefttop':
        return Alignment.topLeft;
      case 'topright':
      case 'righttop':
        return Alignment.topRight;
      case 'bottomleft':
      case 'leftbottom':
        return Alignment.bottomLeft;
      case 'bottomright':
      case 'rightbottom':
        return Alignment.bottomRight;
      default:
        if (align.contains(',')) {
          final parts = align.split(',');
          return Alignment(
            double.tryParse(parts[0]) ?? 0,
            double.tryParse(parts[1]) ?? 0,
          );
        }
    }
    return Alignment.topLeft;
  }

  static Color parseHex(String color) {
    if (color.startsWith('#')) {
      color = color.substring(1);
    }
    if (color.startsWith('0x')) {
      color = color.substring(2);
    }
    if (color.length == 3) {
      color =
          '${color[0]}${color[0]}${color[1]}${color[1]}${color[2]}${color[2]}';
    }
    if (color.length == 6) {
      color = 'FF$color';
    }
    if (color.length != 8) {
      return const Color(0xFF000000);
    }
    return Color(int.parse(color, radix: 16));
  }

  static bool isNetwork(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  static const _alphas = 'abcdefghijklmnopqrstuvwxyz';
  static const _upperAlphas = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _numbers = '0123456789';

  static String randomString(
    int length, {
    String? prefix,
    bool isName = true,
    bool withUpperCase = true,
    bool withLowerCase = true,
    bool withNumber = true,
  }) {
    final builder = StringBuffer(prefix ?? '');
    final rand = math.Random();
    final baseStr =
        '${withUpperCase ? _upperAlphas : ''}${withLowerCase ? _alphas : ''}${withNumber ? _numbers : ''}';
    if (baseStr.isEmpty) {
      throw Exception('no any word to use.');
    }
    if (isName && (prefix == null || prefix.isEmpty)) {
      final base2Str =
          '${withUpperCase ? _upperAlphas : ''}${withLowerCase ? _alphas : ''}';
      if (base2Str.isNotEmpty) {
        int randIndex = rand.nextInt(base2Str.length);
        builder.write(base2Str[randIndex]);
      }
    }

    while (builder.length < length) {
      int randIndex = rand.nextInt(baseStr.length);
      builder.write(baseStr[randIndex]);
    }

    return builder.toString();
  }

  static Future<String> getTempDir({String name = ''}) async {
    final tempPath = await getTemporaryDirectory();
    final path = '${tempPath.path}/$name';
    if (DeviceInfo().lowerAndroidQ) {
      if (!await Permission.storage.isGranted) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Access denied');
        }
      }
    }

    Directory(path).createSync(recursive: true);
    return path;
  }

  static bool isUrl(String result) {
    return result.startsWith('http://') || result.startsWith('https://');
  }
}

Future<void> preloadAssetsImage(
  ImageProvider provider, {
  Size? size,
  ImageErrorListener? onError,
}) {
  final ImageConfiguration config = ImageConfiguration(bundle: rootBundle);
  final Completer<void> completer = Completer<void>();
  final ImageStream stream = provider.resolve(config);
  ImageStreamListener? listener;
  listener = ImageStreamListener(
    (ImageInfo? image, bool sync) {
      if (!completer.isCompleted) {
        completer.complete();
      }

      SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
        stream.removeListener(listener!);
      });
    },
    onError: (Object exception, StackTrace? stackTrace) {
      if (!completer.isCompleted) {
        completer.complete();
      }
      stream.removeListener(listener!);
      if (onError != null) {
        onError(exception, stackTrace);
      } else {
        FlutterError.reportError(
          FlutterErrorDetails(
            context: ErrorDescription('image failed to precache'),
            library: 'image resource service',
            exception: exception,
            stack: stackTrace,
            silent: true,
          ),
        );
      }
    },
  );
  stream.addListener(listener);
  return completer.future;
}
