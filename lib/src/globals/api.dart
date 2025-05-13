import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../models/base.dart';
import '../models/system.dart';
import '../models/user.dart';
import 'api_service.dart';

part 'api/ucenter.dart';

class Api {
  static final ucenter = ApiUcenter();
}

abstract class ApiBase {
  final apiService = ApiService();

  String? get defaultLang => apiService.defaultLang;

  String get basePath;

  void lock() {
    apiService.lock();
  }

  void unLock([bool complete = true]) {
    apiService.unLock(complete);
  }
}
