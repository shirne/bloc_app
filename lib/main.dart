import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:blocapp/src/common.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded<void>(
    () async {
      final storeService = await StoreService.getInstance();

      if (!kIsWeb && Platform.isAndroid) {
        await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(
            true);

        final swAvailable = await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE,
        );
        final swInterceptAvailable =
            await AndroidWebViewFeature.isFeatureSupported(
          AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
        );

        if (swAvailable && swInterceptAvailable) {
          final serviceWorkerController =
              AndroidServiceWorkerController.instance();

          await serviceWorkerController
              .setServiceWorkerClient(AndroidServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              log.d(request);
              return null;
            },
          ));
        }
      }

      runApp(MainApp(storeService));
    },
    (Object e, StackTrace s) {
      log.e(
        'Caught unhandled exception: $e',
        e,
        s,
      );
      if (e is DioError && e.type == DioErrorType.cancel) {
        MyDialog.toast('$e');
      } else {
        MyDialog.popup(Text('$e'));
      }
    },
  );
}
