part of '../api.dart';

class ApiUcenter extends ApiBase {
  @override
  String get basePath => 'auth';

  Future<ApiResult<UserModel>> doLogin(String email, String password) async {
    return await apiService.post(
      '$basePath/login',
      {'email': email, 'password': password},
      skipLock: true,
    );
  }

  Future<ApiResult<TokenModel>> doRefresh(String refreshToken) async {
    return await apiService.post(
      '$basePath/refresh',
      {'refresh_token': refreshToken},
      skipLock: true,
    );
  }

  Future<ApiResult<UserModel>> doRegister({
    required String email,
    required String mobile,
    required String smsCode,
    String? password,
  }) async {
    return await apiService.post(
      '$basePath/register',
      {
        'email': email,
        'mobile': mobile,
        'smsCode': smsCode,
        'password': password,
      },
      skipLock: true,
    );
  }

  Future<ApiResult<Model>> doSendSms(String mobile) async {
    return await apiService.post(
      '$basePath/captcha',
      {'mobile': mobile},
      skipLock: true,
    );
  }

  Future<ApiResult<Model>> doCheck(
    String value, [
    String type = 'mobile',
  ]) async {
    return await apiService.post(
      '$basePath/check',
      {'val': value, 'type': type},
      skipLock: true,
    );
  }

  Future<ApiResult<UserModel>> getUserinfo([
    VoidCallback? onRequireLogin,
  ]) async {
    return await apiService.get(
      'user/profile',
      skipLock: true,
    );
  }

  Future<ApiResult<Model>> getNoticeCount([
    VoidCallback? onRequireLogin,
  ]) async {
    return await apiService.get(
      'user/notice_count',
      skipLock: true,
    );
  }
}
