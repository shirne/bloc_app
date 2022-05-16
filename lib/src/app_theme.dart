import 'package:flutter/material.dart';

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
