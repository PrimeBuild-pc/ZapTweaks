import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/app/app_metadata.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('app, package and installer versions match', () {
    final packageVersion = RegExp(
      r'^version:\s*([^+\r\n]+)',
      multiLine: true,
    ).firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1);
    final installerVersion = RegExp(
      r'^#define AppVersion "([^"]+)"',
      multiLine: true,
    ).firstMatch(File('installer.iss').readAsStringSync())!.group(1);

    expect(AppMetadata.semanticVersion, packageVersion);
    expect(AppMetadata.semanticVersion, installerVersion);
  });
}
