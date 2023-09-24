import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../l10n/gen/l10n.dart';
import '../models/user.dart';
import '../utils/utils.dart';
import '../utils/core.dart';

class StoreService {
  static const userTokenKey = 'user_token';
  static const needAuthKey = 'need_auth';
  static const agreedKey = 'pricity_agreed';

  late SharedPreferences _sp;
  Future<void> init() async {
    _sp = await SharedPreferences.getInstance();
  }

  SharedPreferences get sp => _sp;

  @visibleForTesting
  set sp(SharedPreferences store) => _sp = store;

  static StoreService? _instance;

  factory StoreService() {
    return _instance ??= StoreService._();
  }

  StoreService._();

  bool getAgreed() => _sp.getBool(agreedKey) ?? false;

  Future<void> setAgreed(bool val) => _sp.setBool(agreedKey, val);

  ThemeMode themeMode() {
    String? theme = sp.getString('theme');
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    switch (theme) {
      case ThemeMode.light:
        sp.setString('theme', 'light');
        break;
      case ThemeMode.dark:
        sp.setString('theme', 'dark');
        break;
      default:
        sp.remove('theme');
    }
  }

  Locale? locale() {
    final locale = sp.getString('locale');
    return AppLocalizations.supportedLocales
        .firstWhereOrNull((l) => locale.toString() == locale);
  }

  Future<void> updateLocale(Locale? locale) async {
    if (locale == null) {
      sp.remove('locale');
    } else {
      sp.setString('locale', locale.toString());
    }
  }

  TokenModel token() {
    String? jsonData = sp.getString(userTokenKey);
    if (jsonData != null && jsonData.isNotEmpty) {
      try {
        return TokenModel.fromJson(jsonDecode(jsonData));
      } catch (_) {
        deleteToken();
        logger.warning(
          'user auth decode failed: $jsonData',
          Exception('user auth decode failed: $jsonData'),
          StackTrace.current.cast(5),
        );
      }
    }
    return TokenModel.empty;
  }

  Future<bool> deleteToken() async {
    await sp.remove(needAuthKey);
    return await sp.remove(userTokenKey);
  }

  Future<bool> updateToken(TokenModel token) async {
    return await sp.setString(userTokenKey, jsonEncode(token.toJson()));
  }

  bool needAuth() => sp.getBool(needAuthKey) ?? false;

  Future<void> setNeedAuth(bool needTouchID) async {
    await sp.setBool(needAuthKey, needTouchID);
  }
}
