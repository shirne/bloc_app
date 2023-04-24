import 'package:flutter/material.dart';

import '../../l10n/gen/l10n.dart';
import '../app_theme.dart';

/// 基于核心库的扩展

/// 获取可空的元素
extension ListExtension<E> on List<E> {
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
}

/// 时间计算
extension DateTimeExtension on DateTime {
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
}

extension StringExtension on String {
  int toInt() => int.parse(this);

  double toDouble() => double.parse(this);

  int? toIntOrNull() => int.tryParse(this);

  double? toDoubleOrNull() => double.tryParse(this);
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
}

StackTrace? castStackTrace(StackTrace? trace, [int lines = 3]) {
  if (trace != null) {
    return StackTrace.fromString(
      trace.toString().split('\n').sublist(0, lines).join('\n'),
    );
  }
  return null;
}

extension StackTraceExt on StackTrace {
  StackTrace cast(int lines) {
    return castStackTrace(this, lines)!;
  }
}