import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/windows_version.dart';

void main() {
  test('native Windows version reports the host build', () {
    expect(windowsBuildNumber(), greaterThan(0));
  });
}
