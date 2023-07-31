import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common.dart';
import 'bloc.dart';

class LoginPage extends StatefulWidget {
  final String? backPage;
  final Object? arguments;
  LoginPage(Map<String, dynamic>? args, {Key? key})
      : backPage = args?['back'] as String?,
        arguments = args?['arguments'],
        super(key: key);

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
    if (backPage == null) {
      logger.fine("no last route");
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Routes.home.replace(context);
      }
    } else {
      logger.fine("last route $backPage");

      Navigator.of(context)
          .pushReplacementNamed(backPage!, arguments: widget.arguments);
    }
  }

  @override
  void didUpdateWidget(covariant LoginPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (canClose &&
        !isMarkedClose &&
        context.read<GlobalBloc>().state.user.isValid) {
      isMarkedClose = true;
      SchedulerBinding.instance.addPostFrameCallback((v) => close());
    }
  }

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
                  width: MediaQuery.of(context).size.width * 0.8,
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
                                'assets/images/logo.png',
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.userLogin,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: InputDecoration(
                          hintText: context.l10n.labelUsername,
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: context.l10n.labelPassword,
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        child: Center(
                          child: Text(context.l10n.loginButtonText),
                        ),
                      ),
                      const SizedBox(height: 16),
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
