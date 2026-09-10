import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Italian expose the same user-facing keys', () async {
    Set<String> keys(String file) =>
        (jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>).keys
            .where((key) => !key.startsWith('@'))
            .toSet();

    expect(keys('lib/l10n/app_it.arb'), keys('lib/l10n/app_en.arb'));
  });
}
