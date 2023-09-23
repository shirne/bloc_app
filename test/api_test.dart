import 'dart:io';

import 'package:blocapp/src/common.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  setUp(() async {
    final storeService = StoreService();

    GlobalBloc(storeService);
    GlobalBloc.instance.add(LocaleChangedEvent(const Locale('zh', 'CN')));
  });

  test('api', () async {
    final result = await Api.ucenter.doCheck('0101');
    expect(result.status, 200);

    final result2 = await Api.ucenter.doLogin('shirne@126.com', '123456');
    expect(result2.status, 200);
  });
}
