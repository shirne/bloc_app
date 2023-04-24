import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import 'src/app.dart';
import 'src/globals/store_service.dart';
import 'src/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  handleError();

  final storeService = await StoreService.getInstance();
  await preloadAssetsImage(const AssetImage('assets/images/background.png'));
  runApp(MainApp(storeService));
}

void handleError() {
  PlatformDispatcher.instance.onError = (e, s) {
    if (e is DioError && e.type == DioErrorType.cancel) {
      return false;
    }
    logger.warning('Caught unhandled exception: $e', e, s);
    MyDialog.toast('$e');
    return true;
  };
  ErrorWidget.builder = (FlutterErrorDetails d) {
    logger.warning(
      'Error has been delivered to the ErrorWidget: ${d.exception}',
      d.exception,
      d.stack,
    );
    return Material(
      type: MaterialType.transparency,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Colors.redAccent,
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const FractionallySizedBox(
                widthFactor: 0.25,
                child: FlutterLogo(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Flutter Error',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Text(
                d.exception.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                d.stack.toString(),
                style: const TextStyle(fontSize: 13),
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  };
}
