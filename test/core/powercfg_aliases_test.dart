import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  // A wrong alias (IDLEDEMOTETHR) made a tweak apply nothing and read nothing.
  test(
    'every powercfg alias in the CPU tweaks exists on this Windows',
    () async {
      final source = File(
        'lib/models/power_cpu_tweaks.dart',
      ).readAsStringSync();
      final aliases = <String>{
        for (final match in RegExp(
          r"sub_processor ([A-Z0-9]+)|_readPowercfgValues\('([A-Z0-9]+)'\)",
        ).allMatches(source))
          match.group(1) ?? match.group(2)!,
      };
      expect(aliases, contains('IDLEDEMOTE'));
      for (final alias in aliases) {
        final result = await Process.run('powercfg', <String>[
          '/qh',
          'scheme_current',
          'sub_processor',
          alias,
        ]);
        expect(result.exitCode, 0, reason: '$alias: ${result.stdout}');
      }
    },
    skip: !Platform.isWindows,
  );
}
