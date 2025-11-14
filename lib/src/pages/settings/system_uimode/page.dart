import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common.dart';
import 'bloc.dart';

class SystemUIModePage extends StatelessWidget {
  const SystemUIModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SystemUIModeBloc>(
      create: (context) => SystemUIModeBloc(),
      child: Scaffold(
        appBar: AppBar(
          actions: [Row(mainAxisAlignment: MainAxisAlignment.end)],
        ),
        body: BlocBuilder<SystemUIModeBloc, SystemUIModeState>(
          builder: (context, state) {
            return Column(
              children: [
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Contrast Enforced'),
                    Switch.adaptive(
                      value: state.contrastEnforced,
                      onChanged: (b) {
                        context.read<SystemUIModeBloc>().updateContrastEnforced(
                          b,
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark.copyWith(
                        systemStatusBarContrastEnforced: state.contrastEnforced,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarContrastEnforced:
                            state.contrastEnforced,
                      ),
                    );
                  },
                  child: Text('immersive'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.immersiveSticky,
                    );
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark.copyWith(
                        systemStatusBarContrastEnforced: state.contrastEnforced,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarContrastEnforced:
                            state.contrastEnforced,
                      ),
                    );
                  },
                  child: Text('immersiveSticky'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark.copyWith(
                        systemStatusBarContrastEnforced: state.contrastEnforced,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarContrastEnforced:
                            state.contrastEnforced,
                      ),
                    );
                  },
                  child: Text('leanBack'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.edgeToEdge,
                    );
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark.copyWith(
                        systemStatusBarContrastEnforced: state.contrastEnforced,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarContrastEnforced:
                            state.contrastEnforced,
                      ),
                    );
                  },
                  child: Text('edgeToEdge'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.manual,
                      overlays: [SystemUiOverlay.top],
                    );
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark.copyWith(
                        systemStatusBarContrastEnforced: state.contrastEnforced,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarContrastEnforced:
                            state.contrastEnforced,
                      ),
                    );
                  },
                  child: Text('manual top'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.manual,
                      overlays: [SystemUiOverlay.bottom],
                    );
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark.copyWith(
                        systemStatusBarContrastEnforced: state.contrastEnforced,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarContrastEnforced:
                            state.contrastEnforced,
                      ),
                    );
                  },
                  child: Text('manual bottom'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    SystemChrome.setEnabledSystemUIMode(
                      SystemUiMode.manual,
                      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
                    );
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle.dark.copyWith(
                        systemStatusBarContrastEnforced: state.contrastEnforced,
                        systemNavigationBarColor: Colors.transparent,
                        systemNavigationBarContrastEnforced:
                            state.contrastEnforced,
                      ),
                    );
                  },
                  child: Text('manual both'),
                ),
                Container(alignment: .center),
              ],
            );
          },
        ),
      ),
    );
  }
}
