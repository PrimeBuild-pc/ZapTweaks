import 'dart:convert';
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
                ? '{"settings":[{"target":"global:rsc","template":"Global","field":"rsc","value":"Enabled","configuredValue":"Enabled","effectiveValue":null,"configurationStore":"NetOffloadGlobalSetting","inheritance":"none","supportedValues":["Disabled","Enabled"],"writable":true}]}'
                : 'OK',
            '',
          );
        },
      );
      final service = WindowsTcpOptimizerService(processRunner: runner);

      final expected = await service.inspect('global:rsc');
      await service.write('global:rsc', 'Disabled', expected: expected);
      expect(call, 2);
      await expectLater(
        service.write('global:rsc', 'arbitrary command', expected: expected),
        throwsA(isA<StateError>()),
      );
    },
  );

  test(
    'TCP missing or inherited configuration remains read-only, not an effective-value snapshot',
    () async {
      final rows = [
        {
          'target': 'template:InternetCustom:autotuning',
          'template': 'InternetCustom',
          'field': 'autotuning',
          'value': 'Normal',
          'configuredValue': 'Normal',
          'effectiveValue': 'Disabled',
          'configurationStore': 'NetTCPSetting',
          'inheritance': 'policyOrUnknown',
          'supportedValues': ['Normal', 'Disabled'],
          'writable': true,
        },
        {
          'target': 'global:rss',
          'template': 'Global',
          'field': 'rss',
          'value': 'Enabled',
          'supportedValues': ['Enabled', 'Disabled'],
          'writable': true,
        },
      ];
      var writes = 0;
      final runner = ProcessRunner(
        processRunDelegate:
            (executable, arguments, {runInShell = false}) async {
              final script = utf8
                  .decode(base64Decode(arguments.last))
                  .replaceAll('\u0000', '');
              if (script.contains('\nSet-NetOffloadGlobalSetting -')) writes++;
              return ProcessResult(1, 0, jsonEncode({'settings': rows}), '');
            },
      );
      final service = WindowsTcpOptimizerService(processRunner: runner);
      final states = await service.inventory();
      expect(states.every((item) => !item.exactlyRestorable), isTrue);
      expect(states.first.configuredValue, 'Normal');
      expect(states.first.effectiveValue, 'Disabled');
      await expectLater(
        service.write('global:rss', 'Disabled', expected: states.last),
        throwsStateError,
      );
      expect(writes, 0);
    },
  );

  test('localized non-JSON inventory is rejected without a write', () async {
    var calls = 0;
    final service = WindowsTcpOptimizerService(
      processRunner: ProcessRunner(
        processRunDelegate:
            (executable, arguments, {runInShell = false}) async {
              calls++;
              return ProcessResult(
                1,
                0,
                'Stato ricezione lato scaling: abilitato',
                '',
              );
            },
      ),
    );
    await expectLater(service.inspect('global:rss'), throwsFormatException);
    expect(calls, 1);
    await expectLater(
      service.write(
        'global:rss;whoami',
        'Enabled',
        expected: const TcpSettingState(
          target: 'global:rss',
          template: 'Global',
          field: 'rss',
          value: 'Enabled',
          supportedValues: ['Enabled'],
          writable: true,
        ),
      ),
      throwsFormatException,
    );
    expect(calls, 1);
  });

  test(
    'native write pins the operation baseline instead of rebasing to a fresh inspect',
    () async {
      var calls = 0;
      final runner = ProcessRunner(
        processRunDelegate: (executable, arguments, {runInShell = false}) async {
          calls++;
          final script = utf8
              .decode(base64Decode(arguments.last))
              .replaceAll('\u0000', '');
          expect(
            script,
            contains(
              "FromBase64String('${base64Encode(utf8.encode('Disabled'))}')",
            ),
          );
          expect(
            script,
            contains('TCP configured state drifted before write.'),
          );
          expect(
            script,
            contains('Get-NetOffloadGlobalSetting -ErrorAction Stop'),
          );
          expect(
            script,
            contains('Set-NetOffloadGlobalSetting -ReceiveSideScaling'),
          );
          return ProcessResult(
            1,
            1,
            '',
            'TCP configured state drifted before write.',
          );
        },
      );
      final service = WindowsTcpOptimizerService(processRunner: runner);
      const expected = TcpSettingState(
        target: 'global:rss',
        template: 'Global',
        field: 'rss',
        value: 'Disabled',
        configuredValue: 'Disabled',
        configurationStore: 'NetOffloadGlobalSetting',
        inheritance: 'none',
        supportedValues: ['Disabled', 'Enabled'],
        writable: true,
      );
      await expectLater(
        service.write('global:rss', 'Enabled', expected: expected),
        throwsA(anything),
      );
      expect(calls, 1);
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
