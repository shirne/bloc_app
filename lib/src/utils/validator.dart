import 'package:flutter/widgets.dart';

import '../utils/global_mobile.dart';

/// 表单验证
abstract class Validator<T> {
  String error;

  Validator(this.error);

  bool isValid(T value);

  String? call(T value) => isValid(value) ? null : error;

  Validator<T> and(Validator<T> other, {String error = ''}) {
    return MultiValidator([this, other], error: error);
  }

  Validator<T> or(Validator<T> other, {String error = ''}) {
    return MultiValidator(
      [this, other],
      isAnd: false,
      error: error,
    );
  }
}

class MultiValidator<T> extends Validator<T> {
  MultiValidator(this.validators, {this.isAnd = true, String error = ''})
      : super(error);

  final List<Validator<T>> validators;

  final bool isAnd;

  @override
  bool isValid(T value) {
    for (var v in validators) {
      if (v.isValid(value)) {
        if (!isAnd) {
          return true;
        }
      } else {
        if (isAnd) {
          error = v.error;
          return false;
        }
      }
    }
    return isAnd;
  }
}

class RequiredValidator extends Validator<String?> {
  RequiredValidator([String error = 'Required']) : super(error);

  @override
  bool isValid(String? value) => (value ?? '').isNotEmpty;
}

class LengthValidator extends Validator<String?> {
  LengthValidator(this.minLength, this.maxLength, [String? error])
      : super(error ?? 'Required length $minLength-$maxLength');

  final int minLength;
  final int maxLength;

  @override
  bool isValid(String? value) {
    if (value == null) return false;
    if (value.characters.length < minLength) return false;
    if (value.characters.length > maxLength) return false;
    return true;
  }
}

abstract class RegExpValidator extends Validator<String?> {
  RegExpValidator({
    this.allowEmpty = true,
    String error = '',
    this.caseSensitive = false,
  }) : super(error);

  final bool allowEmpty;
  final bool caseSensitive;
  String get pattern;

  @override
  bool isValid(String? value) {
    if ((value ?? '').isEmpty) return allowEmpty;
    return RegExp(
      pattern,
      caseSensitive: caseSensitive,
    ).hasMatch(value!);
  }
}

class EmailValidator extends RegExpValidator {
  EmailValidator([String error = 'Email is invalid']) : super(error: error);

  @override
  String get pattern =>
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
}

class GlobalPhoneValidator extends Validator<String?> {
  GlobalPhoneValidator([this.code, String error = 'Invalid phone number.'])
      : super(error);

  final int? code;

  @override
  bool isValid(String? value) {
    if (value != null && value.isNotEmpty) {
      String phone, codestr = '';
      if (code == null && value.contains('-')) {
        [codestr, phone] = value.split('-');
      } else {
        phone = value;
      }

      return GlobalMobileVerify.verify(
        phone,
        code: code ?? int.tryParse(codestr),
      );
    }
    return true;
  }
}

class MobileValidator extends RegExpValidator {
  MobileValidator([String error = 'Invalid mobile number.'])
      : super(error: error);

  @override
  String get pattern => r'^1[3-9]\d{9}$';
}

class CodeValidator extends RegExpValidator {
  CodeValidator({
    this.length = 4,
    this.withAlphabet = false,
    String error = 'Invalid code.',
  }) : super(error: error);

  final int length;
  final bool withAlphabet;

  @override
  String get pattern => '^[0-9${withAlphabet ? 'a-z' : ''}]{$length}\$';
}

class PasswordValidator extends RegExpValidator {
  PasswordValidator([
    String error = 'Password must consist of 6-20 characters.',
  ]) : super(error: error);

  // 6 - 20位字母組合
  @override
  String get pattern => r'^[a-z0-9A-Z_]{6,20}$';
}

class EqualValidator extends Validator<String?> {
  final TextEditingController input;

  EqualValidator(this.input, {String error = 'Does not match the password.'})
      : super(error);

  @override
  bool isValid(String? value) {
    if ((value ?? '').isEmpty) return true;
    return input.value.text == value;
  }
}

class AmountValidator extends RegExpValidator {
  AmountValidator([String error = 'Amount is invalid.']) : super(error: error);

  @override
  String get pattern =>
      r'(^[1-9]([0-9]+)?(\.[0-9]{1,2})?$)|(^(0){1}$)|(^[0-9]\.[0-9]([0-9])?$)';
}

class UsernameValidator extends RegExpValidator {
  UsernameValidator([
    this.minLength = 6,
    this.maxLength = 20,
    String? error,
  ]) : super(
          error: error ??
              'Username must consist of $minLength-$maxLength characters.',
        );

  final int minLength;
  final int maxLength;

  // 6 - 30位字母組合
  @override
  String get pattern =>
      '^[a-zA-Z][a-z0-9A-Z]{${minLength - 1},${maxLength - 1}}\$';
}

class NicknameValidator extends RegExpValidator {
  NicknameValidator([
    this.minLength = 6,
    this.maxLength = 20,
    String? error,
  ]) : super(
          error: error ??
              'Nickname must consist of $minLength-$maxLength characters.',
        );

  final int minLength;
  final int maxLength;

  @override
  String get pattern =>
      '^[\\S][ \\S]{${minLength - 2},${maxLength - 2}}[\\S]\$';
}
