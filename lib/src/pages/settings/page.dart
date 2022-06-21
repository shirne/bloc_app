import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../generated/l10n.dart';
import '../../globals/global_bloc.dart';
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
              title: Text(S.of(context).settings),
            ),
            body: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(S.of(context).theme),
                    subtitle: Text(S.of(context).themeDesc),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
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
                    ]),
                    onTap: () async {
                      final result = await showCupertinoModalPopup<ThemeMode>(
                          context: context,
                          builder: (context) {
                            return CupertinoActionSheet(
                              title: Text(S.of(context).themeMode),
                              actions: [
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context, ThemeMode.system);
                                  },
                                  child: Text(S.of(context).themeSystem),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context, ThemeMode.light);
                                  },
                                  child: Text(S.of(context).themeLight),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context, ThemeMode.dark);
                                  },
                                  child: Text(S.of(context).themeDark),
                                ),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(S.of(context).cancel),
                              ),
                            );
                          });
                      if (result != null) {
                        context
                            .read<GlobalBloc>()
                            .add(ThemeModeChangedEvent(result));
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
