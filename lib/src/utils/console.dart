import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../globals/config.dart';
import '../globals/routes.dart';
import '../globals/store_service.dart';
import '../widgets/line_separater.dart';
import 'core.dart';

const _showConsoleKey = 'open_console';
const _logLevel = 'log_level';
const _consoleXKey = 'console_x';
const _consoleYKey = 'console_y';

final logs = <LogRecord>[];

final _opened = ValueNotifier(false);

final store = StoreService();
final buttonKey = GlobalKey();

int _maxSize = 100;

OverlayEntry? consoleEntry;
Offset? consolePosition;
final logScrollController = ScrollController();
final logTimeFmt = DateFormat('HH:mm:ss.SSS');

void initConsole([int maxSize = 300]) async {
  _maxSize = maxSize;
  var showed = store.get<bool>(_showConsoleKey);
  var px = store.get<double>(_consoleXKey);
  var py = store.get<double>(_consoleYKey);
  if (px != null && py != null) {
    consolePosition = Offset(px, py);
  }
  if (showed == true) {
    showConsole();
  }
}

Level getLevel() {
  var level = store.get<String>(_logLevel);
  if (level != null) {
    return Level.LEVELS.firstWhereOrNull((l) => l.name == level) ??
        (Config.env == Env.dev ? Level.ALL : Level.WARNING);
  }
  return Config.env == Env.dev ? Level.ALL : Level.INFO;
}

void setLevel(Level level) {
  store.set<String>(_logLevel, level.name);
}

void addLog(LogRecord log) {
  if (logs.length > _maxSize) {
    logs.removeLast();
  }
  logs.insert(0, log);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (consoleEntry?.mounted == true) {
      consoleEntry?.markNeedsBuild();
    }
  });
}

void clearLog() {
  logs.clear();
}

Offset? _startPosition;
final offsetMove = ValueNotifier(Offset.zero);

void showConsole() {
  store.set(_showConsoleKey, true);
  if (consoleEntry == null) {
    consolePosition ??= const Offset(
      16,
      16 + kBottomNavigationBarHeight,
    );

    consoleEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              right: consolePosition!.dx,
              bottom: consolePosition!.dy,
              child: ValueListenableBuilder(
                valueListenable: _opened,
                builder: (context, isOpen, child) {
                  return Visibility(visible: !isOpen, child: child!);
                },
                child: GestureDetector(
                  onPanDown: (details) {
                    _startPosition = details.globalPosition;
                  },
                  onPanStart: (details) {
                    _startPosition ??= details.globalPosition;
                  },
                  onPanUpdate: (details) {
                    if (_startPosition == null) return;
                    offsetMove.value = details.globalPosition - _startPosition!;
                  },
                  onPanEnd: (details) {
                    setPosition(consolePosition! - offsetMove.value);
                    offsetMove.value = Offset.zero;
                  },
                  onPanCancel: () {
                    offsetMove.value = Offset.zero;
                  },
                  child: ValueListenableBuilder(
                    valueListenable: offsetMove,
                    builder: (context, offset, child) {
                      return Transform.translate(
                        offset: offset,
                        child: child,
                      );
                    },
                    child: Material(
                      color: Colors.blue,
                      shape: const CircleBorder(),
                      key: buttonKey,
                      child: IconButton(
                        onPressed: () {
                          openConsole();
                        },
                        icon: const Icon(Icons.bug_report, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: kToolbarHeight + 28,
              left: 0,
              bottom: 0,
              right: 0,
              child: ValueListenableBuilder(
                valueListenable: _opened,
                builder: (context, isOpen, child) {
                  return Visibility(visible: isOpen, child: child!);
                },
                child: Material(
                  elevation: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Text('Logs'),
                              const Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  closeConsole();
                                  final result = await MyDialog.prompt(
                                    defaultValue: '$_maxSize',
                                    onConfirm: (v) {
                                      var r = int.tryParse(v);
                                      return r != null && r > 10;
                                    },
                                  );
                                  if (result != null) {
                                    _maxSize = int.tryParse(result) ?? _maxSize;
                                  }
                                  openConsole();
                                },
                                child: Text('MAX: $_maxSize'),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  closeConsole();
                                  final result =
                                      await showCupertinoModalPopup<Level>(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoActionSheet(
                                        title: const Text('Set log level'),
                                        actions: [
                                          for (var l in Level.LEVELS)
                                            CupertinoActionSheetAction(
                                              onPressed: () {
                                                Navigator.pop(context, l);
                                              },
                                              child: Text(l.name),
                                            ),
                                        ],
                                        cancelButton:
                                            CupertinoActionSheetAction(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(context.l10n.cancel),
                                        ),
                                      );
                                    },
                                  );
                                  if (result != null) {
                                    Logger.root.level = result;
                                    setLevel(result);
                                    consoleEntry!.markNeedsBuild();
                                  }
                                  openConsole();
                                },
                                child: Text(Logger.root.level.name),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  closeConsole();
                                  final result =
                                      await MyDialog.confirm('Clear logs?');
                                  if (result != null) {
                                    clearLog();
                                  }
                                  openConsole();
                                },
                                child: const Text('Clear'),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  FlutterError.reportError(
                                    FlutterErrorDetails(
                                      exception: Exception('Upload logs'),
                                    ),
                                  );
                                },
                                child: const Icon(Icons.upload),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  closeConsole();
                                },
                                child: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                        const Line(),
                        Expanded(
                          child: ListView.separated(
                            controller: logScrollController,
                            itemCount: logs.length,
                            reverse: true,
                            shrinkWrap: logs.length < 10,
                            separatorBuilder: (context, index) {
                              return const Line();
                            },
                            itemBuilder: (context, index) {
                              return LogItem(logs[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    navigatorKey.currentState?.overlay?.insert(consoleEntry!);
  }
}

void hideConsole() {
  store.set(_showConsoleKey, false);
  closeConsole();
  consoleEntry?.remove();
  consoleEntry = null;
}

void setPosition(Offset? offset, [bool save = false]) {
  if (offset == null) {
    consolePosition = null;
    hideConsole();
    store.del(_consoleXKey);
    store.del(_consoleYKey);
  } else {
    var display = View.of(navigatorKey.currentContext!).physicalSize;
    var btnSize = buttonKey.currentContext?.size ?? const Size.square(60);
    consolePosition = Offset(
      offset.dx.clamp(0, display.width - btnSize.width),
      offset.dy.clamp(0, display.height - btnSize.height),
    );
    consoleEntry?.markNeedsBuild();
    if (save) {
      store.set<double>(_consoleXKey, consolePosition!.dx);
      store.set<double>(_consoleYKey, consolePosition!.dy);
    }
  }
}

void openConsole() {
  _opened.value = true;
}

void closeConsole() {
  _opened.value = false;
}

class LogItem extends StatelessWidget {
  const LogItem(this.record, {super.key});

  final LogRecord record;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () {
        MyDialog.toast('copied');
        Clipboard.setData(
          ClipboardData(text: record.error?.toString() ?? record.message),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${record.time.format(logTimeFmt)} ',
                style: context.textTheme.bodySmall,
              ),
              TextSpan(
                text: '${record.level.name} ',
                style: context.textTheme.titleSmall,
              ),
              TextSpan(
                text: '${record.loggerName} ',
                style: context.textTheme.titleSmall,
              ),
              TextSpan(text: record.message),
              if (record.error != null)
                TextSpan(
                  text: '\n${record.error}',
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: context.colorScheme.error),
                ),
              if (record.stackTrace != null)
                TextSpan(
                  text: ' StackTrace',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      var size =
                          View.of(navigatorKey.currentContext!).physicalSize;
                      late EntryController controller;
                      controller = MyDialog.overlayModal(
                        GestureDetector(
                          onTap: () {
                            controller.close();
                          },
                          child: Container(
                            color: Colors.black26,
                            constraints: BoxConstraints(
                              minHeight: size.height / 2,
                              maxHeight: size.height - kToolbarHeight,
                            ),
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: () {},
                              child: Material(
                                elevation: 8,
                                color: Colors.white,
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: SelectableText(
                                        record.stackTrace.toString(),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          controller.close();
                                        },
                                        child: const Icon(Icons.close),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        animate: AnimationConfig.enter(
                          transform: Matrix4.identity()..translate(0.0, 50.0),
                          opacity: 0,
                          duration: const Duration(milliseconds: 200),
                        ),
                      );
                    },
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: Colors.blue),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
