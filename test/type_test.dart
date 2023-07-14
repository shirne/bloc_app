import 'package:blocapp/src/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('default', () {
    expect(null, getDefault());
    expect(0, getDefault<int>());
    expect(0.0, getDefault<double>());
    expect(BigInt.zero, getDefault<BigInt>());
    expect(0, getDefault<DateTime>().millisecondsSinceEpoch);
    expect('', getDefault<String>());
    expect('[]', getDefault<List>().toString());
    expect(emptyJson, getDefault<Json>());
    expect('{}', getDefault<Map>().toString());
    expect(null, getDefault<int?>());
  });
}
