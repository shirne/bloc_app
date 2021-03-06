import 'dart:ui';

import 'package:logger/logger.dart';

import '../globals/config.dart';

final log = Logger(
  filter:
      Config.env == Env.development ? DevelopmentFilter() : ProductionFilter(),
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: false,
  ),
);

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
}
