import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common.dart';
import 'bloc.dart';

/// 登录页
class LoginPage extends StatefulWidget {
  LoginPage(Json? args, {super.key})
      : backPage = args?['back'] as String?,
        arguments = args?['arguments'];

  final String? backPage;
  final Object? arguments;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? backPage;
  bool canClose = true;
  bool isMarkedClose = false;

  @override
  void initState() {
    super.initState();
    if (widget.backPage != null && widget.backPage != Routes.login.name) {
      backPage = widget.backPage;
    }
  }

  void close() {
    if (isMarkedClose) return;
    isMarkedClose = true;
    final navigator = Navigator.of(context);
    if (backPage == null || backPage == Routes.login.name) {
      logger.fine("no last route");
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        Routes.main.replace(context);
      }
    } else {
      logger.fine("last route $backPage ${widget.arguments}");

      navigator.pushReplacementNamed(
        backPage!,
        arguments: widget.arguments,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GlobalBloc, GlobalState>(
      listener: (context, globalState) {
        if (canClose && globalState.token.isValid) {
          close();
        }
      },
      builder: (context, state) {
        return Navigator(
          initialRoute: '/',
          onGenerateRoute: (RouteSettings routeSettings) {
            final route = Routes.match(routeSettings);
            if (route == null ||
                route.name == Routes.login.name ||
                route.name == '/') {
              return MaterialPageRoute<dynamic>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  return const LoginScreen();
                },
              );
            }

            if (route.isAuth) {
              backPage = route.name;
              close();
            }

            return MaterialPageRoute<dynamic>(
              settings: routeSettings,
              builder: (BuildContext context) {
                return route.builder.call(routeSettings.arguments);
              },
            );
          },
        );
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.l10n.login),
            ),
            body: Center(
              child: Card(
                child: Container(
                  width: math.min(MediaQuery.of(context).size.width * 0.8, 450),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20,
                        child: OverflowBox(
                          alignment: Alignment.bottomCenter,
                          maxHeight: 80,
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                Assets.images.logo,
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Gap.v(8),
                      Text(
                        context.l10n.userLogin,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap.v(8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: context.l10n.labelUsername,
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const Gap.v(16),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: context.l10n.labelPassword,
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      const Gap.v(16),
                      BlocBuilder<LoginBloc, LoginState>(
                        buildWhen: (previous, current) {
                          return previous.status != current.status;
                        },
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: state.isLoading
                                ? null
                                : () {
                                    context
                                        .read<LoginBloc>()
                                        .add(SubmitEvent());
                                  },
                            child: Center(
                              child: Text(context.l10n.loginButtonText),
                            ),
                          );
                        },
                      ),
                      const Gap.v(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(context.l10n.forgotPassword),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(context.l10n.createAccount),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
