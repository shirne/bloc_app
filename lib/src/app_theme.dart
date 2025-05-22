import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

/// 扩展的主题数据
class AppTheme extends ThemeExtension<AppTheme> {
  final ButtonStyle? primaryButton;
  final ButtonStyle? secondaryButton;
  AppTheme({
    this.primaryButton,
    this.secondaryButton,
  });

  factory AppTheme.of(BuildContext context) {
    return Theme.of(context).extension<AppTheme>()!;
  }

  static ThemeData widgetStyle(ThemeData base, AppTheme extTheme) {
    final isDark = base.brightness == Brightness.dark;
    return base.copyWith(
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        backgroundColor:
            isDark ? base.colorScheme.surface : base.colorScheme.primary,
        foregroundColor:
            isDark ? base.colorScheme.onSurface : base.colorScheme.onPrimary,
      ),
      cardTheme: const CardThemeData(
        elevation: 20,
      ),
      listTileTheme: ListTileThemeData(
        tileColor: base.colorScheme.surface,
        selectedTileColor: base.colorScheme.primary.withAlpha(20),
      ),
      extensions: [extTheme, const ShirneDialogTheme()],
    );
  }

  static ThemeData lightTheme() {
    final themeData = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5AA7A7),
      ),
    );
    return widgetStyle(themeData, AppTheme());
  }

  static ThemeData darkTheme() {
    final themeData = ThemeData.from(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5AA7A7),
        brightness: Brightness.dark,
      ),
    );

    return widgetStyle(themeData, AppTheme());
  }

  @override
  AppTheme copyWith({
    ButtonStyle? primaryButton,
    ButtonStyle? secondaryButton,
  }) {
    return AppTheme(
      primaryButton: primaryButton ?? this.primaryButton,
      secondaryButton: secondaryButton ?? this.secondaryButton,
    );
  }

  @override
  AppTheme lerp(ThemeExtension<AppTheme>? other, double t) {
    if (other == null || other is! AppTheme) {
      return copyWith();
    }
    return copyWith(
      primaryButton: primaryButton?.merge(other.primaryButton),
      secondaryButton: secondaryButton?.merge(other.secondaryButton),
    );
  }
}
