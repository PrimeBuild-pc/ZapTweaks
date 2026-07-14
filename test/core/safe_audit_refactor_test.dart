import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/models/recovered_script_tweaks.dart';

void main() {
  test('safe audit preserves actions and PowerShell encoding', () async {
    final tweaks = createRecoveredScriptTweaks();
    expect(tweaks, hasLength(92));
    expect(tweaks.map((item) => item.id).toSet(), hasLength(92));

    late List<String> capturedArguments;
    final runner = ProcessRunner(
      processRunDelegate:
          (
            String executable,
            List<String> arguments, {
            bool runInShell = false,
          }) async {
            expect(executable, 'powershell');
            capturedArguments = arguments;
            return ProcessResult(0, 0, ' result ', '');
          },
    );

    const script = 'Write-Output "è"';
    expect(await runner.runPowerShellForOutput(script), 'result');

    final bytes = base64Decode(capturedArguments.last);
    final decoded = String.fromCharCodes(<int>[
      for (var index = 0; index < bytes.length; index += 2)
        bytes[index] | (bytes[index + 1] << 8),
    ]);
    expect(decoded, script);
  });
}
