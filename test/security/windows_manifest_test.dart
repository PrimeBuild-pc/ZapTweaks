import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main application starts without elevation', () {
    final manifest = File(
      'windows/runner/runner.exe.manifest',
    ).readAsStringSync();

    expect(manifest, contains('requestedExecutionLevel level="asInvoker"'));
    expect(manifest, isNot(contains('level="requireAdministrator"')));
  });
}
