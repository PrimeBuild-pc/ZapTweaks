import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/models/reference_tweaks.dart';

void main() {
  // Each PowerShell here costs ~1.5 s at launch; 47 of them ran at startup.
  test(
    'registry and service state checks start no process',
    () async {
      final launched = <String>[];
      final previous = ProcessRunner.shared;
      addTearDown(() => ProcessRunner.configureShared(previous));
      ProcessRunner.configureShared(
        ProcessRunner(
          processStartDelegate:
              (
                String executable,
                List<String> arguments, {
                bool runInShell = false,
                Map<String, String>? environment,
              }) async {
                launched.add(executable);
                throw StateError('no process expected');
              },
        ),
      );
      final native = createReferenceTweaks().where(
        (tweak) =>
            tweak is ServiceDisabledTweak ||
            (tweak is PowerShellStateTweak && tweak.check != null),
      );
      expect(native.length, greaterThanOrEqualTo(47));
      for (final tweak in native) {
        await tweak.checkState();
      }
      expect(launched, isEmpty);
      expect(await serviceDisabled('ZapTweaksNoSuchService'), isFalse);
    },
    skip: !Platform.isWindows,
  );
}
