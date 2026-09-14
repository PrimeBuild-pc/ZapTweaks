import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/appx_removal_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/services/process_runner.dart';

class _Runner extends ProcessRunner {
  bool installed = true;
  String? appliedScript;

  @override
  Future<String> runPowerShellForOutput(String script) async =>
      installed ? '1' : '0';

  @override
  Future<void> runPowerShellScript(
    String script, {
    bool elevated = false,
  }) async {
    appliedScript = script;
    installed = false;
  }
}

void main() {
  const context = OperationContext(windowsBuild: 26100, edition: 'Pro');

  test(
    'AppX removal validates scope, snapshots, applies and verifies absence',
    () async {
      final runner = _Runner();
      final operation = AppxRemovalOperation(
        id: 'app.appx.remove_system',
        systemScopes: true,
        processRunner: runner,
      );
      const request = OperationRequest(
        operationId: 'app.appx.remove_system',
        target: 'Microsoft.Sample',
        desiredValue: null,
        parameters: <String, Object?>{'scope': 'provisioned'},
      );

      expect((await operation.supports(context, request)).supported, isTrue);
      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);

      expect(snapshot.data['scope'], 'provisioned');
      expect(runner.appliedScript, contains('Remove-AppxProvisionedPackage'));
      expect((await operation.verify(request)).kind, OperationStateKind.absent);
    },
  );

  test('AppX removal rejects untrusted identities before execution', () async {
    final operation = AppxRemovalOperation(
      id: 'app.appx.remove_current_user',
      systemScopes: false,
      processRunner: _Runner(),
    );
    const request = OperationRequest(
      operationId: 'app.appx.remove_current_user',
      target: "Bad'; Remove-Item C:\\\\*; #",
      desiredValue: null,
      parameters: <String, Object?>{'scope': 'currentUser'},
    );

    expect((await operation.supports(context, request)).supported, isFalse);
    expect(() => operation.apply(request), throwsStateError);
  });
}
