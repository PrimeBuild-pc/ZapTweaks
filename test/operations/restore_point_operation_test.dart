import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/restore_point_operation.dart';
import 'package:script_utility/core/services/process_runner.dart';

class _Runner extends ProcessRunner {
  _Runner({this.fail = false})
    : super(mode: ProcessExecutionMode.dryRun, dryRunDelay: Duration.zero);

  final bool fail;
  final scripts = <String>[];
  String latest = '';

  @override
  Future<String> runPowerShellForOutput(String script) async {
    scripts.add(script);
    if (script.contains('Checkpoint-Computer')) {
      if (fail) throw Exception('System Restore is turned off.');
      latest = RegExp(r"-Description '([^']*)'").firstMatch(script)![1]!;
      return '';
    }
    return latest;
  }
}

OperationRequest _request(String description, {bool enable = false}) =>
    OperationRequest(
      operationId: 'system.restore_point.create',
      desiredValue: true,
      parameters: <String, Object?>{
        'description': description,
        'enableProtection': enable,
      },
    );

void main() {
  test(
    'creates the point despite the 24 h limit, then restores the limit',
    () async {
      final runner = _Runner();
      final op = RestorePointOperation(processRunner: runner);

      await op.apply(_request('ZapTweaks before uninstall'));

      final script = runner.scripts.single;
      expect(script, contains("SystemRestorePointCreationFrequency"));
      expect(script, contains('finally'));
      expect(script, isNot(contains('Enable-ComputerRestore')));
      expect(
        (await op.verify(_request('ZapTweaks before uninstall'))).value,
        isTrue,
      );
    },
  );

  test('turns System Protection on only when asked', () async {
    final runner = _Runner();
    await RestorePointOperation(
      processRunner: runner,
    ).apply(_request('ZapTweaks preset', enable: true));
    expect(runner.scripts.single, contains('Enable-ComputerRestore'));
  });

  test('a disabled System Protection surfaces as an error', () async {
    await expectLater(
      RestorePointOperation(
        processRunner: _Runner(fail: true),
      ).apply(_request('ZapTweaks preset')),
      throwsA(anything),
    );
  });

  test('descriptions that could break out of the script are refused', () async {
    final op = RestorePointOperation(processRunner: _Runner());
    for (final bad in ["x'; Remove-Item C:\\", '', 'a' * 65, r'$(evil)']) {
      expect(
        (await op.supports(
          const OperationContext(windowsBuild: 26100, edition: 'Pro'),
          _request(bad),
        )).supported,
        isFalse,
        reason: bad,
      );
    }
  });
}
