import 'package:flutter/widgets.dart';

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

class PhoneValidator extends RegExpValidator {
  PhoneValidator([String error = 'Invalid phone number.'])
      : super(error: error);

  @override
  String get pattern => r'^1[3-9]\d{9}$';
}

class PasswordValidator extends RegExpValidator {
  PasswordValidator([
    String error = 'Password must consist of 8-12 characters.',
  ]) : super(error: error);

  // 8 - 12位字母組合
  //final Pattern _pattern = r'^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,12}$';
  @override
  String get pattern => r'^[a-z0-9A-Z]{8,12}$';
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
