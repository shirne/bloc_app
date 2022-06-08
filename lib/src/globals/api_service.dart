import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

import '../../generated/l10n.dart';
import '../models/base.dart';
import '../models/user.dart';
import '../utils/utils.dart';
import 'config.dart';
import 'routes.dart';

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

  static Future<ApiResult<Model>> doCheck(String value,
      [String type = 'mobile']) async {
    return await apiService.post(
      apiCheck,
      {'val': value, 'type': type},
      skipLock: true,
    );
  }
}

typedef DataParser<T> = T Function(dynamic);

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

  bool isLoginShow = false;

  Dio get dio => _dio;
  final Dio _dio;

  ApiService._(
    this.baseUrl, {
    this.connectTimeout,
    this.sendTimeout,
    this.receiveTimeout,
  }) : _dio = Dio(BaseOptions(
          connectTimeout: connectTimeout,
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
          baseUrl: baseUrl,
        )) {
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
      log.d('api locked');
      _locker = Completer<bool>();
    }
  }

  /// 解锁
  void unLock([bool complete = true]) {
    if (isLocked) {
      log.d('api unlocked');
      _locker?.complete(complete);
    }
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
  }) async {
    if (!skipLock && isLocked) {
      log.d('api is locked');
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
      Response<Map<String, dynamic>> res = await _dio.request(
        src,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      final result = ApiResult<T>.fromResponse(res, dataParser);
      if (result.status == 401) {
        if (!isLoginShow) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            isLoginShow = true;
            showCupertinoDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return CupertinoAlertDialog(
                    title: Text(S.of(context).loginDialogTitle),
                    content: Text(S.of(context).loginDialogContent),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(S.of(context).no),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                      CupertinoDialogAction(
                        child: Text(S.of(context).yes),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    ],
                  );
                }).then((goLogin) {
              if (goLogin ?? false) {
                Routes.login.show(context);
              }
            }).whenComplete(() {
              isLoginShow = false;
            });
          }
        }
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
  }) async {
    return request(
      src,
      'GET',
      header: header,
      queryParameters: queryParameters,
      dataParser: dataParser,
      skipLock: skipLock,
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
  }) async {
    return request(
      src,
      'POST',
      data: data,
      header: header,
      queryParameters: queryParameters,
      dataParser: dataParser,
      skipLock: skipLock,
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
  }) async {
    return request(
      src,
      'PUT',
      data: data,
      header: header,
      queryParameters: queryParameters,
      dataParser: dataParser,
      skipLock: skipLock,
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
  }) async {
    return request(
      src,
      'DELETE',
      data: data,
      header: header,
      queryParameters: queryParameters,
      dataParser: dataParser,
      skipLock: skipLock,
    );
  }
}

class ApiResult<T extends Base> {
  final int status;
  final String message;
  final T? data;
  final Map<String, dynamic>? debug;

  bool get failed => status != 200;
  bool get success => status == 200;
  bool get needLogin => status == 401;
  bool get unauthorized => status == 403;

  ApiResult(this.status, this.message, [this.data, this.debug]);
  ApiResult.fromResponse(
    Response<Map<String, dynamic>> response, [
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
      return Base.fromJson<T>(data.isEmpty ? null : {'list': data});
    }

    return Base.fromJson<T>(data);
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data,
        'debug': debug,
      };

  @override
  String toString() => toJson().toString();
}

class ApiInterceptor extends Interceptor {
  final Logger log;
  ApiInterceptor() : log = Logger();
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    log.i('网络请求',
        '${options.path} ${options.method}\n\nHeader：${options.headers}\n\nQueryParameters：${options.queryParameters}\n\nRequestData：${options.data}');

    super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    var requestOptions = response.requestOptions;

    log.i('网络请求响应',
        '${requestOptions.path} ${requestOptions.method} ${response.statusCode}\n\nHeader：${response.headers}\nResponseData：${response.data}');

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    log.e('网络请求错误', err.error);
    return super.onError(err, handler);
  }
}
