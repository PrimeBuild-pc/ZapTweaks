import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/platform/windows/windows_version.dart';

void main() {
  test('native Windows version reports a supported Windows 11 build', () {
    expect(windowsBuildNumber(), greaterThanOrEqualTo(22000));
  });
}
