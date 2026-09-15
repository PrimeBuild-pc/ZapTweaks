import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/system_uptime.dart';

void main() {
  test('current Windows boot predates the running test', () {
    expect(windowsRebootedSince(DateTime.now().toUtc()), isFalse);
  });
}
