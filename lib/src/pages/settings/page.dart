import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

import '../../common.dart';
import '../../utils/console.dart';
import 'bloc.dart';

/// 系统设置页(多语言，主题切换)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider<SettingsBloc>(
      create: (context) => SettingsBloc(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: Text(context.l10n.settings)),
            body: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(context.l10n.theme),
                    subtitle: Text(context.l10n.themeDesc),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.read<GlobalBloc>().state.themeMode.name,
                          style: theme.textTheme.bodySmall,
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onTap: () async {
                      final bloc = context.read<GlobalBloc>();
                      final result = await showCupertinoModalPopup<ThemeMode>(
                        context: context,
                        builder: (context) {
                          return CupertinoActionSheet(
                            title: Text(context.l10n.themeMode),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context, ThemeMode.system);
                                },
                                child: Text(context.l10n.themeSystem),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context, ThemeMode.light);
                                },
                                child: Text(context.l10n.themeLight),
                              ),
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context, ThemeMode.dark);
                                },
                                child: Text(context.l10n.themeDark),
                              ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(context.l10n.cancel),
                            ),
                          );
                        },
                      );
                      if (result != null) {
                        bloc.add(ThemeModeChangedEvent(result));
                      }
                    },
                  ),
                  ListTile(
                    title: Text(context.l10n.languages),
                    subtitle: Text(context.l10n.languagesDesc),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context
                                  .read<GlobalBloc>()
                                  .state
                                  .locale
                                  ?.translate() ??
                              '-',
                          style: theme.textTheme.bodySmall,
                        ),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onTap: () async {
                      final bloc = context.read<GlobalBloc>();
                      final result = await showCupertinoModalPopup<Locale>(
                        context: context,
                        builder: (context) {
                          return CupertinoActionSheet(
                            title: Text(context.l10n.languages),
                            actions: [
                              CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context, const Locale('_'));
                                },
                                child: Text(context.l10n.themeSystem),
                              ),
                              for (var locale
                                  in AppLocalizations.supportedLocales)
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context, locale);
                                  },
                                  child: Text(locale.translate()),
                                ),
                            ],
                            cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(context.l10n.cancel),
                            ),
                          );
                        },
                      );
                      if (result != null) {
                        bloc.add(
                          LocaleChangedEvent(
                            result.languageCode == '_' ? null : result,
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    title: Text(context.l10n.systemUIMode),
                    subtitle: Text(context.l10n.systemUIModeDesc),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [const Icon(Icons.arrow_forward_ios)],
                    ),
                    onTap: () {
                      Navigator.of(
                        context,
                      ).pushNamed(Routes.settingsSystemUimode.name);
                    },
                  ),
                  RawGestureDetector(
                    gestures: {
                      SerialTapGestureRecognizer:
                          GestureRecognizerFactoryWithHandlers<
                            SerialTapGestureRecognizer
                          >(() => SerialTapGestureRecognizer(), (recognizer) {
                            recognizer.onSerialTapDown = (details) async {
                              if (details.count > 4) {
                                final isOpen = await MyDialog.confirm(
                                  'Open Logs?',
                                  buttonText: 'Open',
                                  cancelText: 'Close',
                                );
                                if (isOpen == true) {
                                  showConsole();
                                } else if (isOpen == false) {
                                  hideConsole();
                                }
                              }
                            };
                          }),
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(height: 30, color: Colors.transparent),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
