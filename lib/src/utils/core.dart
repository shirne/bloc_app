import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/gen/l10n.dart';
import '../app_theme.dart';
import 'utils.dart';

/// 基于核心库的扩展

typedef ResultCallback<T> = void Function(bool, T? data);

/// 获取可空的元素
extension ListExt<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : this[0];

  E? firstWhereOrNull(bool Function(E) test) {
    for (E item in this) {
      if (test.call(item)) {
        return item;
      }
    }
    return null;
  }

  E? singleOrNull(bool Function(E) test) {
    E? matched;
    for (E item in this) {
      if (test(item)) {
        if (matched != null) return null;
        matched = item;
      }
    }
    return matched;
  }

  List<List<E>> chunk(int size) {
    return List.generate(
      (length / size).ceil(),
      (i) => sublist(i * size, math.min(i * size + size, length)),
    );
  }

  int indexOr(bool Function(E) test, [int dft = 0]) {
    if (isEmpty) return -1;
    final index = indexWhere(test);
    if (index < 0) return dft;
    return index;
  }
}

extension IntListExt on List<int> {
  String hex([int width = 2]) {
    return map<String>((i) => i.toRadixString(16).padLeft(width, '0')).join('');
  }
}

/// 时间计算
extension DateTimeExtension on DateTime {
  int get secondsSinceEpoch => millisecondsSinceEpoch ~/ 1000;

  DateTime startOfDay() {
    return DateTime(year, month, day, 0, 0, 0, 0, 0);
  }

  DateTime endOfDay() {
    return DateTime(year, month, day, 23, 59, 59, 999, 999);
  }

  /// `offset`=-1时以周日起始
  DateTime startOfWeek([int offset = 0]) {
    return DateTime(year, month, day + 1 + offset - weekday, 0, 0, 0, 0, 0);
  }

  /// `offset`=-1时以周日起始
  DateTime endOfWeek([int offset = 0]) {
    return DateTime(
      year,
      month,
      day + 7 + offset - weekday,
      23,
      59,
      59,
      999,
      999,
    );
  }

  DateTime startOfMonth() {
    return DateTime(year, month, 1, 0, 0, 0, 0, 0);
  }

  DateTime endOfMonth() {
    int endDay = 31;
    if (month == 2) {
      if ((year % 400 == 0) || (year % 100 != 0 && year % 4 == 0)) {
        endDay = 29;
      } else {
        endDay = 28;
      }
    } else if ([4, 6, 9, 11].contains(month)) {
      endDay = 30;
    }
    return DateTime(year, month, endDay, 23, 59, 59, 999, 999);
  }

  String format([DateFormat? formater]) {
    return (formater ?? datetimeFmt).format(this);
  }

  String friendly() {
    var today = DateTime.now().startOfDay();
    if (isAfter(today)) {
      return format(hmFmt);
    }
    if (isAfter(today.subtract(const Duration(days: 3)))) {
      return format(dtWFmt);
    }
    if (year == DateTime.now().year) {
      return format(dtFmt);
    }
    return format(dateFmt);
  }

  /// return the earlier date
  DateTime beforeIf(DateTime? other) {
    if (other == null) return this;
    final diff = difference(other);
    if (diff.isNegative) {
      return this;
    }
    return other;
  }

  /// return the later date
  DateTime afterIf(DateTime? other) {
    if (other == null) return this;
    final diff = difference(other);
    if (diff.isNegative) {
      return other;
    }
    return this;
  }
}

extension IntExt on int {
  DateTime toDate([bool isMillion = false]) {
    if (isMillion) {
      return DateTime.fromMillisecondsSinceEpoch(this);
    }
    return DateTime.fromMillisecondsSinceEpoch(this * 1000);
  }

  String toHex([int length = 2]) => toRadixString(16).padLeft(length, '0');
}

extension StringExt on String {
  int toInt() => int.parse(this);

  double toDouble() => double.parse(this);

  int? toIntOrNull() => int.tryParse(this);

  double? toDoubleOrNull() => double.tryParse(this);

  String addPrefix(String prefix) {
    return '$prefix$this';
  }

  String addSuffix(String suffix) {
    return '$this$suffix';
  }

  ImageProvider<Object>? toImage() {
    if (isEmpty) return null;
    if (Utils.isNetwork(this)) {
      return NetworkImage(this);
    }
    if (Utils.isAssets(this)) {
      return AssetImage(this);
    }
    return FileImage(File(this));
  }

  String cut(int len, {String suffix = '...'}) {
    if (length <= len) {
      return this;
    }
    return '${substring(0, len)}$suffix';
  }

  String? notEmpty() {
    if (isEmpty) {
      return null;
    }
    return this;
  }
}

extension StringNullExt on String? {
  String ifEmpty(String other) {
    if (this == null || this?.isEmpty == true) {
      return other;
    }
    return this!;
  }
}

extension ObjectExt on Object? {
  bool isNullOrEmpty() {
    if (this == null) {
      return true;
    }
    if (this is String) {
      return (this as String).isEmpty;
    }
    if (this is Iterable) {
      return (this as Iterable).isEmpty;
    }
    if (this is List) {
      return (this as List).isEmpty;
    }
    if (this is Set) {
      return (this as Set).isEmpty;
    }
    if (this is Map) {
      return (this as Map).isEmpty;
    }

    try {
      return (this as dynamic).isEmpty;
    } catch (_) {}

    return false;
  }
}

extension ColorExt on Color {
  String toRgb([String typeName = 'Color']) =>
      '$typeName(${(r * 255).toInt()},${(g * 255).toInt()},${(b * 255).toInt()})';
  String toHex([String prefix = '#']) =>
      '$prefix${(r * 255).toInt().toHex(2)}${(g * 255).toInt().toHex(2)}${(b * 255).toInt().toHex(2)}';
}

extension LocaleExt on Locale {
  String translate() {
    switch (languageCode) {
      case 'zh':
        switch (countryCode) {
          case 'CN':
            return '中文简体';
          case 'ZH':
            return '中文繁體';
          default:
            return '中文';
        }
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
    }
    return 'Unsupported';
  }
}

extension BuildContextExtension on BuildContext {
  NavigatorState get navigator => Navigator.of(this);

  ThemeData get theme => Theme.of(this);

  AppTheme get appTheme => theme.extension<AppTheme>()!;

  TextTheme get textTheme => theme.textTheme;

  Brightness get brightness => theme.brightness;

  ButtonThemeData get buttonTheme => ButtonTheme.of(this);

  ButtonStyle get elevatedButtonStyle => theme.elevatedButtonTheme.style!;
  ButtonStyle get outlinedButtonStyle => theme.outlinedButtonTheme.style!;
  ButtonStyle get textButtonStyle => theme.textButtonTheme.style!;

  IconThemeData get iconTheme => IconTheme.of(this);

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  double get topPadding => mediaQuery.padding.top;

  double get bottomPadding => mediaQuery.padding.bottom;

  double get bottomViewInsets => mediaQuery.viewInsets.bottom;

  ColorScheme get colorScheme => theme.colorScheme;

  Color get surfaceColor => colorScheme.surface;

  AppLocalizations get l10n => AppLocalizations.of(this)!;

  Locale get locale => Localizations.localeOf(this);
}

StackTrace? castStackTrace(StackTrace? trace, [int lines = 3]) {
  if (trace != null) {
    final errors = trace.toString().split('\n');
    return StackTrace.fromString(
      errors.sublist(0, math.min(lines, errors.length)).join('\n'),
    );
  }
  return null;
}

extension StackTraceExt on StackTrace {
  StackTrace cast(int lines) {
    return castStackTrace(this, lines)!;
  }
}

extension FunctionExt on Function {
  void Function() debounce([Duration duration = const Duration(seconds: 1)]) {
    return Debounce(this, duration).call;
  }
}

class Debounce<F extends Function> {
  F callable;
  int argCount = 0;

  Duration duration;

  int lastTime = 0;

  Debounce(this.callable, [this.duration = const Duration(milliseconds: 500)]);

  void call([arg1, arg2, arg3, arg4, arg5]) {
    final time = DateTime.now().millisecondsSinceEpoch;
    if (time - lastTime < duration.inMilliseconds) {
      logger.info('debounced $callable');
      return;
    }
    lastTime = time;
    switch (argCount) {
      case 1:
        callable(arg1);
        return;
      case 2:
        callable(arg1, arg2);
        return;
      case 3:
        callable(arg1, arg2, arg3);
        return;
      case 4:
        callable(arg1, arg2, arg3, arg4);
        return;
      case 5:
        callable(arg1, arg2, arg3, arg4, arg5);
        return;
    }
    callable();
  }
}

class Optional<T> {
  Optional(this.value);

  final T? value;
}

extension OptionalExt<T> on Optional<T>? {
  T? absent(T? value) {
    return this == null ? value : this?.value;
  }
}
