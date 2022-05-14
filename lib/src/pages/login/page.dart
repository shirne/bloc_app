import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../generated/l10n.dart';
import '../../globals/global_bloc.dart';
import '../../globals/routes.dart';
import '../../utils/utils.dart';
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
      log.i("no last route");
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Routes.root.replace(context);
      }
    } else {
      log.i("last route $backPage");

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
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(),
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).login),
            ),
            body: Center(
              child: Card(
                child: Container(
                  width: 800.w,
                  height: 800.w,
                  padding: EdgeInsets.all(60.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 60.w,
                        child: OverflowBox(
                          alignment: Alignment.bottomCenter,
                          maxHeight: 200.w,
                          child: SizedBox(
                            width: 200.w,
                            height: 200.w,
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 200.w,
                                height: 200.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.w),
                      Text(
                        '会员登录',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 40.w),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '用户名',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      SizedBox(height: 40.w),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '密码',
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      SizedBox(height: 40.w),
                      ElevatedButton(
                          onPressed: () {},
                          child: Center(
                            child: Text('登录'),
                          )),
                      SizedBox(height: 40.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(onPressed: () {}, child: Text('找回密码')),
                          TextButton(onPressed: () {}, child: Text('注册新用户')),
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
