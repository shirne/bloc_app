import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../common.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(init);
  }

  Future<void> init(_) async {
    // TODO 此处可加入协议弹窗

    await Future.wait([
      initWeb(),
      initGlobal(),
      Future.delayed(const Duration(seconds: 1)),
    ]);
    // ignore: use_build_context_synchronously
    Routes.home.replace(context);
  }

  Future<void> initWeb() async {
    if (!kIsWeb && Platform.isAndroid) {
      await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

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

        await serviceWorkerController.setServiceWorkerClient(
          AndroidServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              log.d(request);
              return null;
            },
          ),
        );
      }
    }
  }

  Future<bool> initGlobal() async {
    Completer<bool> completer = Completer<bool>();
    context.read<GlobalBloc>().add(
      InitEvent(
        (isReady, _) {
          completer.complete(isReady);
        },
      ),
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  'assets/images/background.png',
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Image.asset(
              'assets/images/splash_logo.png',
              width: 90.25,
              height: 128.75,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/text.png',
              width: 150.25,
              height: 25,
            ),
          ),
        ],
      ),
    );
  }
}
