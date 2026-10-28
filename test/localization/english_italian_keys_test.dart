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

  test('TCP Optimizer copy is present in every available language', () {
    Map<String, dynamic> messages(String file) =>
        jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>;

    final english = messages('lib/l10n/app_en.arb');
    final keys = english.keys.toList();
    final start = keys.indexOf('tcpOptimizer');
    final end = keys.indexOf('openRecoveryHistory');
    expect(start, greaterThanOrEqualTo(0));
    expect(end, greaterThanOrEqualTo(start));
    final featureKeys = keys.sublist(start, end + 1);
    for (final locale in <String>['de', 'es', 'fr', 'it', 'ru', 'zh']) {
      final translated = messages('lib/l10n/app_$locale.arb');
      for (final key in featureKeys) {
        expect(
          translated[key],
          isA<String>().having((value) => value.trim(), key, isNotEmpty),
          reason: '$key is missing from $locale',
        );
      }
    }
  });
}
