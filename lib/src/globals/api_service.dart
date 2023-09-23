import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../models/base.dart';
import '../utils/utils.dart';
import '../utils/core.dart';
import 'config.dart';
import 'global_bloc.dart';
import 'localizations.dart';
import 'routes.dart';

const _tokenHeaderKey = 'Authorization';

class ApiService {
  static ApiService? _instance;
  static ApiService getInstance() {
    _instance ??= ApiService._(Config.serverUrl);
    return _instance!;
  }

  final Duration? connectTimeout;
  final Duration? sendTimeout;
  final Duration? receiveTimeout;
  final String baseUrl;

  /// 防止登录询问窗口多次弹出
  bool _isLoginShow = false;

  String? get defaultLang => GlobalBloc.instance.langTag;

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

  void addToken(String token) {
    addHeader(_tokenHeaderKey, token);
  }

  void removeToken() {
    removeHeader(_tokenHeaderKey);
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
    final toLogin = await MyDialog.confirm(
      Column(
        children: [
          Text(context.l10n.loginDialogTitle),
          Text(context.l10n.loginDialogContent),
        ],
      ),
    );
    if (toLogin == true && context.mounted) {
      Routes.login.show(context);
    }

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
        return ApiResult<T>(0, 'Request canceled');
      }
    }
    Options options = Options(
      method: method,
      headers: {
        'lang': defaultLang,
        ...?header,
      },
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
      if (result.invalidToken) {
        GlobalBloc.instance.add(UserQuitEvent());
      }

      return result;
    } on DioException catch (e) {
      final errmsg = globalL10n.requestError;
      if (e.response != null) {
        final data = e.response!.data is String
            ? {'msg': e.response!.data}
            : as<Json>(e.response!.data) ?? emptyJson;
        final result = ApiResult<T>(
          data['code'] ?? e.response!.statusCode,
          as<String>(data['msg'] ?? data['message'] ?? errmsg)!.trim(),
          null,
        );
        if (result.needLogin) {
          (onRequireLogin ?? _onRequireLogin).call();
        }
        if (result.invalidToken) {
          GlobalBloc.instance.add(UserQuitEvent());
        }
        return result;
      }
      MyDialog.toast(errmsg, iconType: IconType.error);
      return ApiResult<T>(-1, '', null);
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
  ])  : status = response.statusCode ?? -1,
        message = response.statusMessage ?? '',
        data = response.data == null
            ? null
            : dataParser?.call(response.data) ?? transData<T>(response.data),
        debug = response.data?['debug'];

  static T? transData<T>(dynamic data) {
    if (data == null) return null;

    // 基本类型或List,Map
    if (data is T) return data;
    if (data is List<dynamic>) {
      if (data.isEmpty) return null;
      if (T == ModelList) {
        return ModelList.fromJson({'list': data}) as T;
      }
    } else if (data is Json) {
      if (T == Model) {
        return Model.fromJson(data) as T;
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
      '${options.uri} ${options.method}\n'
          'Header：${options.headers}\n'
          'QueryParameters：${options.queryParameters}\n'
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
      '${requestOptions.uri} '
          '${requestOptions.method} ${response.statusCode}\n'
          'Header：${response.headers}\n'
          'ResponseData：${response.data}',
    );

    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    logger.warning(
      '网络请求错误: ${err.message ?? err.error}',
      err.error,
      StackTrace.current.cast(5),
    );
    if (err.response?.data != null) {
      logger.fine(
        '错误数据',
        '${err.response?.data}',
      );
    }

    return super.onError(err, handler);
  }
}
