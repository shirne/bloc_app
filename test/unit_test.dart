import 'package:blocapp/src/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cast test', () {
    expect(as<String>('a'), 'a');
    expect(as<String>(1), '1');
    final date = DateTime.now();
    expect(as<String>(date), '$date');
    expect(as<String>(0.9), '0.9');

    expect(as<int>('a'), null);
    expect(as<int>('1'), 1);
    expect(as<double>('0'), 0.0);
    expect(as<DateTime>('a'), null);
    expect(as<DateTime>('2022-03-04'), DateTime(2022, 3, 4));
    expect(as<DateTime>('2022/03/04'), DateTime(2022, 3, 4));
  });

  test('chunk', () {
    var list = [1, 2, 3, 4, 5, 6];

    expect(3, list.chunk(2).length);
    expect(2, list.chunk(3).length);
    expect(2, list.chunk(4).length);
  });
}
