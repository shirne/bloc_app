import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../common.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Alignment alignment = Alignment.center;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(init);
  }

  Future<void> init(_) async {
    final agreed = StoreService().getAgreed();
    if (!agreed) {
      final size = MediaQuery.of(context).size;
      final errorColor = context.colorScheme.error;
      final assets = 'assets/json/${context.l10n.policy}.html';
      final content = await rootBundle.loadString(assets);

      final controller = ScrollController();
      final confirmed = await MyDialog.confirm(
        SizedBox(
          height: size.height * 0.6,
          child: Scrollbar(
            radius: const Radius.circular(4),
            trackVisibility: true,
            thumbVisibility: true,
            controller: controller,
            child: SingleChildScrollView(
              controller: controller,
              child: HtmlWidget(content),
            ),
          ),
        ),
        barrierDismissible: false,
        buttonText: globalL10n.agree,
        cancelText: globalL10n.reject,
        cancelStyle: TextStyle(color: errorColor),
      );
      if (confirmed != true) {
        exit(0);
      }
      StoreService().setAgreed(true);
    }
    await Future.delayed(Duration.zero);
    if (mounted) {
      setState(() {
        alignment = const Alignment(0, -0.5);
      });
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        //LocatorUtil().init();
        await Future.wait([
          initWeb(),
          initGlobal(),
          initChat(),
          Future.delayed(const Duration(seconds: 1)),
        ]);
        if (mounted) {
          Routes.main.replace(context);
        }
      }
    }
  }

  Future<void> initWeb() async {
    if (!kIsWeb && Platform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(true);

      final swAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_BASIC_USAGE,
      );
      final swInterceptAvailable = await WebViewFeature.isFeatureSupported(
        WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST,
      );

      if (swAvailable && swInterceptAvailable) {
        final serviceWorkerController = ServiceWorkerController.instance();

        await serviceWorkerController.setServiceWorkerClient(
          ServiceWorkerClient(
            shouldInterceptRequest: (request) async {
              logger.info(request);
              return null;
            },
          ),
        );
      }
    }
  }

  Future<bool> initGlobal() async {
    final completer = Completer<bool>();
    context.read<GlobalBloc>().add(
      InitEvent(
        (isReady, _) {
          completer.complete(isReady);
        },
      ),
    );

    return completer.future;
  }

  Future<dynamic> initChat() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
    // return context.findRootAncestorStateOfType<MainAppState>()?.initChat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(Assets.images.background),
                  ),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  Assets.images.splashLogo,
                  width: 90.25,
                  height: 128.75,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  Assets.images.text,
                  width: 150.25,
                  height: 50,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
