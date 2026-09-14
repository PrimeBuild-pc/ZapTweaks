import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/platform/windows/power_scheme_service.dart';

void main() {
  test('PowrProf enumerates schemes and marks exactly one active', () {
    if (!Platform.isWindows) return;

    final schemes = WindowsPowerSchemeService().enumerate();

    expect(schemes, isNotEmpty);
    expect(schemes.where((scheme) => scheme.active), hasLength(1));
    expect(schemes.every((scheme) => scheme.id.isNotEmpty), isTrue);
    expect(schemes.every((scheme) => scheme.name.isNotEmpty), isTrue);
  });
}
