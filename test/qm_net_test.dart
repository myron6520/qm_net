import 'package:flutter_test/flutter_test.dart';

import 'package:qm_net/qm_net.dart';

void main() {
  test('adds one to input values', () async {
    var resp = await Net.get("https://www.baiduc.com", params: {});
    print("resp:${resp.data}");
    print("resp:${resp.msg}");
  });
}
