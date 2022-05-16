import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              title: Text('系统设置'),
            ),
            body: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Theme'),
                    subtitle: Text('Set app theme '),
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
                      Icon(Icons.arrow_forward_ios),
                    ]),
                    onTap: () async {
                      final result = await showCupertinoModalPopup<ThemeMode>(
                          context: context,
                          builder: (context) {
                            return CupertinoActionSheet(
                              title: Text('Theme mode'),
                              actions: [
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context, ThemeMode.system);
                                  },
                                  child: Text('System'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context, ThemeMode.light);
                                  },
                                  child: Text('Light'),
                                ),
                                CupertinoActionSheetAction(
                                  onPressed: () {
                                    Navigator.pop(context, ThemeMode.dark);
                                  },
                                  child: Text('Dark'),
                                ),
                              ],
                              cancelButton: CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('Cancel'),
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
