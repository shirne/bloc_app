import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../generated/l10n.dart';
import 'bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

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
