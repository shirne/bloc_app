import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../utils/utils.dart';
import '../utils/core.dart';

class StoreService {
  static const userTokenKey = 'user_token';
  static const needAuthKey = 'need_auth';

  late SharedPreferences _sp;
  Future<void> init() async {
    _sp = await SharedPreferences.getInstance();
  }

  SharedPreferences get sp => _sp;

  static StoreService? _instance;
  static Future<StoreService> getInstance() async {
    if (_instance == null) {
      _instance = StoreService();
      await _instance!.init();
    }
    return _instance!;
  }

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

  User user() {
    String? jsonData = sp.getString(userTokenKey);
    if (jsonData != null && jsonData.isNotEmpty) {
      try {
        return User.fromJson(jsonDecode(jsonData))..needAuth = needAuth();
      } catch (_) {
        deleteUser();
        logger.warning(
          'user auth decode failed: $jsonData',
          Exception('user auth decode failed: $jsonData'),
          StackTrace.current.cast(5),
        );
      }
    }
    return User();
  }

  Future<bool> deleteUser() async {
    await sp.remove(needAuthKey);
    return await sp.remove(userTokenKey);
  }

  Future<bool> updateUser(User user) async {
    return await sp.setString(userTokenKey, jsonEncode(user.toJson()));
  }

  bool needAuth() => sp.getBool(needAuthKey) ?? false;

  Future<void> setNeedAuth(bool needTouchID) async {
    await sp.setBool(needAuthKey, needTouchID);
  }
}
