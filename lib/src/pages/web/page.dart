import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../../common.dart';

int webviewId = 0;

/// 加载web页(url = 链接, show_app_bar = 是否显示appbar)
class WebViewPage extends StatefulWidget {
  WebViewPage(Json? config, {super.key})
      : url = config?['url'] ?? '',
        showAppBar = config?['show_app_bar'] ?? true;

  final String url;
  final bool showAppBar;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? controller;
  final title = ValueNotifier<String>('...');
  final progress = ValueNotifier<int>(0);

  Widget _buildWebview() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      onWebViewCreated: (controller) {
        // controller.openDevTools();
        this.controller = controller;
      },
      onTitleChanged: (InAppWebViewController controller, String? title) {
        this.title.value = title ?? '';
      },
      onReceivedError: (controller, request, error) {
        logger.warning('onLoadError: ${request.url}, $error');
      },
      onConsoleMessage: (controller, consoleMessage) {
        logger.info(consoleMessage.message);
      },
      // onCreateWindow: (controller, createWindowAction) async {
      //   return false;
      // },
      onCloseWindow: (controller) {
        Navigator.of(context).pop();
      },
      onJsAlert: (controller, jsAlertRequest) async {
        final result = await MyDialog.alert(
          jsAlertRequest.message,
        );
        return JsAlertResponse(
          handledByClient: true,
          action: result == null ? null : JsAlertResponseAction.CONFIRM,
        );
      },
      onJsConfirm: (controller, jsConfirmRequest) async {
        final result = await MyDialog.confirm(
          jsConfirmRequest.message,
        );
        return JsConfirmResponse(
          handledByClient: true,
          action: result == true
              ? JsConfirmResponseAction.CONFIRM
              : JsConfirmResponseAction.CANCEL,
        );
      },
      onJsPrompt: (controller, jsPromptRequest) async {
        final result = await MyDialog.prompt(
          label: jsPromptRequest.message == null
              ? null
              : Text(jsPromptRequest.message!),
          defaultValue: jsPromptRequest.defaultValue,
        );
        return JsPromptResponse(
          value: result,
          handledByClient: true,
          action: result == null
              ? JsPromptResponseAction.CANCEL
              : JsPromptResponseAction.CONFIRM,
        );
      },
      onReceivedHttpError: (controller, request, response) {
        logger.warning(
          'onLoadError: ${request.url}, ${response.statusCode}, ${response.reasonPhrase}',
        );
      },
      onPermissionRequest: (controller, permissionRequest) async {
        return PermissionResponse(
          resources: permissionRequest.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onGeolocationPermissionsShowPrompt:
          (InAppWebViewController controller, String origin) async {
        return GeolocationPermissionShowPromptResponse(
          origin: origin,
          allow: true,
          retain: true,
        );
      },
      onProgressChanged: (InAppWebViewController controller, int progress) {
        this.progress.value = progress;
      },
      initialSettings: InAppWebViewSettings(
        applicationNameForUserAgent: "All Blue APP",
        cacheEnabled: true,
        javaScriptEnabled: true,

        /// 设置false 解决IOS webview 因为拦截Ajax请求而导致显示问题
        //useShouldInterceptAjaxRequest: !Platform.isIOS,
        javaScriptCanOpenWindowsAutomatically: true,
        clearCache: false,
        useShouldOverrideUrlLoading: true,
        useOnLoadResource: true,
        mediaPlaybackRequiresUserGesture: true,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,

        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        //appCachePath: state.appCachePath,
        cacheMode: CacheMode.LOAD_NO_CACHE,
        useHybridComposition: true,
        safeBrowsingEnabled: false,

        allowsInlineMediaPlayback: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: ValueListenableBuilder<String>(
                valueListenable: title,
                builder: (context, value, child) {
                  return Text(value);
                },
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(0),
                child: SizedBox(
                  height: 0,
                  child: ValueListenableBuilder<int>(
                    valueListenable: progress,
                    builder: (context, value, child) {
                      if (value > 0 && value < 100) {
                        return OverflowBox(
                          maxHeight: 2,
                          child: LinearProgressIndicator(
                            value: value.toDouble(),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    controller?.reload();
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            )
          : null,
      body: _buildWebview(),
    );
  }
}
