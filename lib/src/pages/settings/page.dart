import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../globals/global_bloc.dart';
import 'bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    trailing: PopupMenuButton<ThemeMode>(
                      onSelected: (ThemeMode result) {
                        context
                            .read<GlobalBloc>()
                            .add(ThemeModeChangedEvent(result));
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<ThemeMode>>[
                        const PopupMenuItem<ThemeMode>(
                          value: ThemeMode.system,
                          child: Text('System'),
                        ),
                        const PopupMenuItem<ThemeMode>(
                          value: ThemeMode.light,
                          child: Text('Light'),
                        ),
                        const PopupMenuItem<ThemeMode>(
                          value: ThemeMode.dark,
                          child: Text('Dark'),
                        ),
                      ],
                    ),
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
