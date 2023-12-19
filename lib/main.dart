import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'src/app.dart';
import 'src/assets.dart';
import 'src/globals/store_service.dart';
import 'src/utils/console.dart';
import 'src/utils/device_info.dart';
import 'src/utils/utils.dart';
import 'src/widgets/gap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  handleError();

  await Future.wait([
    StoreService().init(),
    preloadAssetsImage(AssetImage(Assets.images.background)),
    DeviceInfo().init(),
  ]);
  Logger.root.level = getLevel();

  runApp(MainApp());
}

void handleError() {
  PlatformDispatcher.instance.onError = (e, s) {
    if (e is DioException && e.type == DioExceptionType.cancel) {
      return false;
    }
    logger.warning('Caught unhandled exception: $e', e, s);
    // MyDialog.toast('$e');

    return true;
  };
  FlutterError.onError = (details) {
    logger.warning(
      'Flutter error: ${details.exception}',
      details.exception,
      details.stack,
    );
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
              const Gap.v(16),
              const Text(
                'Flutter Error',
                style: TextStyle(fontSize: 20),
              ),
              const Gap.v(8),
              Text(
                d.exception.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap.v(8),
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
