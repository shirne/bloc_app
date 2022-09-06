import 'package:blocapp/src/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider<SettingsBloc>(
      create: (context) => SettingsBloc(),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.settings),
            ),
            body: Padding(
              padding: EdgeInsets.all(20.w),
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
                          context
                              .read<GlobalBloc>()
                              .state
                              .themeMode
                              .toString()
                              .replaceFirst('ThemeMode.', ''),
                          style: theme.textTheme.caption,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
