import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/permission_service.dart';
import 'package:script_utility/core/services/process_runner.dart';

void main() {
  test(
    'detects elevation from the current Windows token, not Server service state',
    () async {
      late String executable;
      late List<String> arguments;
      final runner = ProcessRunner(
        processRunDelegate:
            (nextExecutable, nextArguments, {bool runInShell = false}) async {
              executable = nextExecutable;
              arguments = nextArguments;
              return ProcessResult(0, 0, 'true\n', '');
            },
      );

      final elevated = await PermissionService(
        processRunner: runner,
      ).isRunningElevated();

      expect(elevated, isTrue);
      expect(executable, 'powershell');
      expect(arguments.join(' '), contains('WindowsPrincipal'));
      expect(arguments.join(' '), isNot(contains('net session')));
    },
  );
}
