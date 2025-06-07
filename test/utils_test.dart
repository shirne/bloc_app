// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:blocapp/src/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('version', () {
    var v1 = '1.0.1';
    var v2 = '1.0.2';
    expect(-1, Utils.versionCompare(v1, v2));

    v1 = '1.1.1';
    v2 = '1.1';
    expect(1, Utils.versionCompare(v1, v2));
    v1 = '1.1.1';
    v2 = '1.1.01';
    expect(0, Utils.versionCompare(v1, v2));
    v1 = '1.2.1';
    v2 = '1.1.01';
    expect(1, Utils.versionCompare(v1, v2));
    v1 = '1.2.1+121';
    v2 = '1.2.01';
    expect(1, Utils.versionCompare(v1, v2));
    v1 = '1.2.1+121';
    v2 = '1.2.01+123';
    expect(-1, Utils.versionCompare(v1, v2));
  });
}
