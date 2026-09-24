import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/tcp_optimizer_service.dart';

void main() {
  test(
    'TCP inventory consumes structured values independent of display language',
    () async {
      final runner = ProcessRunner(
        processRunDelegate: (executable, arguments, {runInShell = false}) async {
          return ProcessResult(
            1,
            0,
            '{"settings":[{"target":"template:InternetCustom:ecn","template":"InternetCustom","field":"ecn","value":"Disabled","supportedValues":["Disabled","Enabled"],"writable":true},{"target":"global:rss","template":"Global","field":"rss","value":"Enabled","supportedValues":["Disabled","Enabled"],"writable":true}]}',
            '',
          );
        },
      );

      final settings = await WindowsTcpOptimizerService(
        processRunner: runner,
      ).inventory();

      expect(settings, hasLength(2));
      expect(settings.first.value, 'Disabled');
      expect(settings.last.target, 'global:rss');
    },
  );

  test(
    'TCP mutation uses only enumerated values and a fixed command surface',
    () async {
      var call = 0;
      final runner = ProcessRunner(
        processRunDelegate: (executable, arguments, {runInShell = false}) async {
          call++;
          return ProcessResult(
            1,
            0,
            call.isOdd
                ? '{"settings":[{"target":"global:rsc","template":"Global","field":"rsc","value":"Enabled","supportedValues":["Disabled","Enabled"],"writable":true}]}'
                : 'OK',
            '',
          );
        },
      );
      final service = WindowsTcpOptimizerService(processRunner: runner);

      await service.write('global:rsc', 'Disabled');
      expect(call, 2);
      await expectLater(
        service.write('global:rsc', 'arbitrary command'),
        throwsA(isA<StateError>()),
      );
    },
  );

  test('QoS inventory keeps external policies read-only', () async {
    final runner = ProcessRunner(
      processRunDelegate: (executable, arguments, {runInShell = false}) async =>
          ProcessResult(
            1,
            0,
            '{"policies":[{"name":"Corporate","appPath":"C:\\\\Apps\\\\corp.exe","protocol":"TCP","sourcePort":null,"destinationPort":443,"dscp":30,"throttleBitsPerSecond":null,"editable":false}]}',
            '',
          ),
    );

    final policies = await WindowsQosPolicyService(
      processRunner: runner,
    ).inventory();

    expect(policies.single.name, 'Corporate');
    expect(policies.single.editable, isFalse);
  });
}
