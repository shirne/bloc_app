import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import 'package:blocapp/src/common.dart';
import '../models/user.dart';
import 'config.dart';

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

  static Future<ApiResult<User>> doLogin(String email, String password) async {
    return await apiService
        .post(apiLogin, {'email': email, 'password': password}, skipLock: true);
  }

  static Future<ApiResult<User>> doRegister({
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
  static Future<ApiResult<User>> getUserinfo([
    VoidCallback? onRequireLogin,
  ]) async {
    return await apiService.get(
      apiUserinfo,
      skipLock: true,
    );
  }
}

class ApiService {
  static ApiService? _instance;
  static ApiService getInstance() {
    _instance ??= ApiService._(Config.serverUrl);
    return _instance!;
  }

  final int? connectTimeout;
  final int? sendTimeout;
  final int? receiveTimeout;
  final String baseUrl;

  /// 防止登录询问窗口多次弹出
  bool _isLoginShow = false;

  Dio get dio => _dio;
  final Dio _dio;

  ApiService._(
    this.baseUrl, {
    this.connectTimeout,
    this.sendTimeout,
    this.receiveTimeout,
  }) : _dio = Dio(
          BaseOptions(
            connectTimeout: connectTimeout,
            sendTimeout: sendTimeout,
            receiveTimeout: receiveTimeout,
            baseUrl: baseUrl,
          ),
        ) {
    _dio.interceptors.add(ApiInterceptor());
  }

  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  void removeHeader(String key) {
    if (_dio.options.headers.containsKey(key)) {
      _dio.options.headers.remove(key);
    }
  }

  Completer<bool>? _locker;

  bool get isLocked => !(_locker?.isCompleted ?? true);

  /// 锁
  void lock() {
    if (!isLocked) {
      logger.info('api locked');
      _locker = Completer<bool>();
    }
  }

  /// 解锁
  void unLock([bool complete = true]) {
    if (isLocked) {
      logger.info('api unlocked');
      _locker?.complete(complete);
    }
  }

  Future<void> _onRequireLogin() async {
    if (_isLoginShow) return;
    final context = navigatorKey.currentContext;
    if (context == null) return;
    _isLoginShow = true;
    await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(context.l10n.loginDialogTitle),
          content: Text(context.l10n.loginDialogContent),
          actions: [
            CupertinoDialogAction(
              child: Text(context.l10n.no),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            CupertinoDialogAction(
              child: Text(context.l10n.yes),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    ).then((goLogin) {
      if (goLogin ?? false) {
        Routes.login.show(context);
      }
    });
    _isLoginShow = false;
  }

  /// 通用请求
  Future<ApiResult<T>> request<T extends Base>(
    String src,
    String method, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? header,
    DataParser<T>? dataParser,
    bool skipLock = false,
    VoidCallback? onRequireLogin,
  }) async {
    if (!skipLock && isLocked) {
      logger.info('api is locked');
      final isPass = await _locker!.future;
      if (!isPass) {
        return ApiResult<T>(500, 'Request canceled');
      }
    }
    Options options = Options(
      method: method,
      headers: header,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
    );

    try {
      Response<Json> res = await _dio.request(
        src,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      final result = ApiResult<T>.fromResponse(res, dataParser);
      if (result.needLogin) {
        (onRequireLogin ?? _onRequireLogin).call();
      }

      return result;
    } catch (e) {
      return ApiResult(-1, (e is DioError) ? e.message : e.toString(), null);
    }
  }

  /// get请求
  Future<ApiResult<T>> get<T extends Base>(
    String src, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? header,
    DataParser<T>? dataParser,
    bool skipLock = false,
    VoidCallback? onRequireLogin,
  }) async {
    return request(
      src,
      'GET',
      header: header,
      queryParameters: queryParameters,
      dataParser: dataParser,
      skipLock: skipLock,
      onRequireLogin: onRequireLogin,
    );
  }

  /// post请求
  Future<ApiResult<T>> post<T extends Base>(
    String src,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? header,
    DataParser<T>? dataParser,
    bool skipLock = false,
    VoidCallback? onRequireLogin,
  }) async {
    return request(
      src,
      'POST',
      data: data,
      header: header,
      queryParameters: queryParameters,
      dataParser: dataParser,
      skipLock: skipLock,
      onRequireLogin: onRequireLogin,
    );
  }

  /// put请求
  Future<ApiResult<T>> put<T extends Base>(
    String src,
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? header,
    DataParser<T>? dataParser,
    bool skipLock = false,
    VoidCallback? onRequireLogin,
  }) async {
    return request(
      src,
      'PUT',
      data: data,
      header: header,
      queryParameters: queryParameters,
      dataParser: dataParser,
      skipLock: skipLock,
      onRequireLogin: onRequireLogin,
    );
  }

  /// delete请求
  Future<ApiResult<T>> delete<T extends Base>(
    String src, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? header,
    DataParser<T>? dataParser,
    bool skipLock = false,
    VoidCallback? onRequireLogin,
  }) async {
    return request(
      src,
      'DELETE',
      data: data,
      header: header,
      queryParameters: queryParameters,
      dataParser: dataParser,
      skipLock: skipLock,
      onRequireLogin: onRequireLogin,
    );
  }
}

class ApiResult<T extends Base> {
  final int status;
  final String message;
  final T? data;
  final Json? debug;

  bool get failed => status != 200;
  bool get success => status == 200;

  bool get invalidToken => status == 402;
  bool get needLogin => status == 401;
  bool get unauthorized => status == 403;

  ApiResult(this.status, this.message, [this.data, this.debug]);
  ApiResult.fromResponse(
    Response<Json> response, [
    DataParser<T>? dataParser,
  ])  : status = response.data?['status'] ?? -1,
        message = response.data?['message'] ?? '',
        data = response.data?['data'] == null
            ? null
            : dataParser?.call(response.data?['data']) ??
                transData<T>(response.data?['data']),
        debug = response.data?['debug'];

  static T? transData<T>(dynamic data) {
    if (data == null) return null;
    // 基本类型或List,Map
    if (data is T) return data;
    if (data is List<dynamic>) {
      if (data.isEmpty) return null;
      if (T is ModelList) {
        return ModelList.fromJson({'list': data}) as T;
      }
    }
    logger.warning(
      'Data parse error: $T from $data',
      Exception('Data parse error: $T from $data'),
      StackTrace.current.cast(3),
    );

    return null;
  }

  Json toJson() => {
        'status': status,
        'message': message,
        'data': data,
        'debug': debug,
      };

  @override
  String toString() => toJson().toString();
}

class ApiInterceptor extends Interceptor {
  ApiInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    logger.fine(
      '网络请求',
      '${options.path} ${options.method}\n\n'
          'Header：${options.headers}\n\n'
          'QueryParameters：${options.queryParameters}\n\n'
          'RequestData：${options.data}',
    );

    super.onRequest(options, handler);
  }

  @override
  Future onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    var requestOptions = response.requestOptions;

    logger.fine(
      '网络请求响应',
      '${requestOptions.path} '
          '${requestOptions.method} ${response.statusCode}\n\n'
          'Header：${response.headers}\n'
          'ResponseData：${response.data}',
    );

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    logger.warning('网络请求错误', err.error, StackTrace.current.cast(5));
    return super.onError(err, handler);
  }
}
