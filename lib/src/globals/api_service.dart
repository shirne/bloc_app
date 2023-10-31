import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../models/base.dart';
import '../utils/utils.dart';
import '../utils/core.dart';
import 'config.dart';
import 'global_bloc.dart';
import 'routes.dart';

const _tokenHeaderKey = 'Authorization';

class ApiService {
  static final _instances = <String, ApiService>{};
  static ApiService get instance => _instances['_default'] ??= ApiService._(
        Config.serverUrl[0],
        connectTimeout: const Duration(seconds: 10),
      );
  factory ApiService([String? baseUrl, Duration? connectTimeout]) {
    return baseUrl == null
        ? instance
        : _instances.putIfAbsent(
            baseUrl,
            () => ApiService._(baseUrl, connectTimeout: connectTimeout),
          );
  }

  final Duration? connectTimeout;
  final Duration? sendTimeout;
  final Duration? receiveTimeout;

  String get baseUrl => _dio.options.baseUrl;

  FutureOr<void> Function()? onRequest;

  /// 防止登录询问窗口多次弹出
  bool _isLoginShow = false;

  String? get defaultLang => GlobalBloc.instance.langTag;

  Dio get dio => _dio;
  final Dio _dio;

  ApiService._(
    String baseUrl, {
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

  void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
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

    await onRequest?.call();

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
      if (e.response != null) {
        final data = e.response!.data is Json ? e.response!.data : emptyJson;
        final result = ApiResult<T>(
          as<int>(data['code']) ?? e.response!.statusCode ?? 0,
          as<String>(data['msg'] ?? data['message'])?.trim(),
          dataParser?.call(data) ?? ApiResult.transData(data),
          transErrorMsg(e.response!.data),
        );
        if (result.needLogin) {
          (onRequireLogin ?? _onRequireLogin).call();
        }
        if (result.invalidToken) {
          GlobalBloc.instance.add(UserQuitEvent());
        }
        return result;
      }

      return ApiResult<T>(-1, globalL10n.requestError, null);
    }
  }

  dynamic transErrorMsg(dynamic msg) {
    if (msg is String) {
      if (msg.startsWith('<html>')) {
        final tIndex = msg.indexOf('<title>');
        if (tIndex > -1) {
          var eIndex = msg.indexOf('</title>', tIndex + 7);
          return msg.substring(tIndex + 7, eIndex);
        } else {
          return msg.replaceAll(RegExp(r'<[a-zA-Z0-9\-]+[^>]+>'), '');
        }
      }
      return msg.trim();
    }
    return msg;
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
  final String? _message;
  final T? data;
  final dynamic origin;

  String get message =>
      _message ?? (kReleaseMode ? globalL10n.requestError : '$origin');

  bool get failed => status != 200;
  bool get success => status == 200;

  bool get invalidToken => status == 402;
  bool get needLogin => status == 401;
  bool get unauthorized => status == 403;

  ApiResult(this.status, this._message, [this.data, this.origin]);

  ApiResult.fromResponse(
    Response<Json> response, [
    DataParser<T>? dataParser,
  ])  : status = response.statusCode ?? -1,
        _message = response.statusMessage,
        data = response.data == null
            ? null
            : dataParser?.call(response.data) ?? transData<T>(response.data),
        origin = response.data;

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
      } else if (T == ActionResult) {
        return ActionResult.fromJson(data) as T;
      }
    }
    logger.warning(
      'Data parse error: $T from $data',
      Exception('Data parse error: $T from $data'),
      StackTrace.current.cast(5),
    );

    return null;
  }

  Json toJson() => {
        'status': status,
        'message': _message,
        'data': data,
        'origin': origin,
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
      '网络请求错误: ${err.message ?? err.error}\n${err.requestOptions.uri}',
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
