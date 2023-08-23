import 'dart:ui';

import '../models/base.dart';
import '../models/user.dart';
import 'api_service.dart';

class Api {
  static final apiService = ApiService.getInstance();

  static void lock() {
    apiService.lock();
  }

  static void unLock([bool complete = true]) {
    apiService.unLock(complete);
  }

  static const apiTc = '';

  static const apiLogin = 'auth/login';
  static const apiRegister = 'auth/register';
  static const apiSms = 'auth/captcha';
  static const apiCheck = 'auth/check';

  static Future<ApiResult<UserModel>> doLogin(
      String email, String password) async {
    return await apiService
        .post(apiLogin, {'email': email, 'password': password}, skipLock: true);
  }

  static Future<ApiResult<UserModel>> doRegister({
    required String email,
    required String mobile,
    required String smsCode,
    String? password,
  }) async {
    return await apiService.post(
      apiRegister,
      {
        'email': email,
        'mobile': mobile,
        'smsCode': smsCode,
        'password': password,
      },
      skipLock: true,
    );
  }

  static Future<ApiResult<Model>> doSendSms(String mobile) async {
    return await apiService.post(
      apiSms,
      {'mobile': mobile},
      skipLock: true,
    );
  }

  static Future<ApiResult<Model>> doCheck(
    String value, [
    String type = 'mobile',
  ]) async {
    return await apiService.post(
      apiCheck,
      {'val': value, 'type': type},
      skipLock: true,
    );
  }

  static const apiUserinfo = 'user/profile';
  static Future<ApiResult<UserModel>> getUserinfo([
    VoidCallback? onRequireLogin,
  ]) async {
    return await apiService.get(
      apiUserinfo,
      skipLock: true,
    );
  }
}
