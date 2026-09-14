import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/optional_feature_operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/windows_optional_feature_service.dart';
import 'package:script_utility/features/apps/domain/windows_optional_feature.dart';

class _FeatureService extends WindowsOptionalFeatureService {
  _FeatureService()
    : super(processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun));

  bool enabled = false;

  @override
  Future<List<WindowsOptionalFeature>> scan() async => <WindowsOptionalFeature>[
    WindowsOptionalFeature(
      name: 'Sample-Feature',
      state: enabled
          ? WindowsOptionalFeatureState.enabled
          : WindowsOptionalFeatureState.disabled,
    ),
  ];

  @override
  Future<void> setEnabled(String name, bool value) async => enabled = value;
}

class _InventoryRunner extends ProcessRunner {
  @override
  Future<String> runPowerShellForOutput(String script) async =>
      '[{"Name":"One","State":"Enabled"},{"Name":"Two","State":"DisablePending"}]';
}

void main() {
  test('optional feature inventory parses stable state names', () async {
    final features = await WindowsOptionalFeatureService(
      processRunner: _InventoryRunner(),
    ).scan();

    expect(features.first.state, WindowsOptionalFeatureState.enabled);
    expect(features.last.state, WindowsOptionalFeatureState.disablePending);
  });

  test(
    'optional feature operation snapshots, verifies and rolls back',
    () async {
      final service = _FeatureService();
      final operation = OptionalFeatureOperation(service);
      const request = OperationRequest(
        operationId: 'app.optional_feature.set',
        target: 'Sample-Feature',
        desiredValue: true,
      );
      const context = OperationContext(windowsBuild: 26100, edition: 'Pro');

      expect((await operation.supports(context, request)).supported, isTrue);
      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);
      expect((await operation.verify(request)).value, isTrue);
      await operation.rollback(request, snapshot);
      expect(service.enabled, isFalse);
    },
  );

  test('optional feature operation blocks injected names', () async {
    final operation = OptionalFeatureOperation(_FeatureService());
    const request = OperationRequest(
      operationId: 'app.optional_feature.set',
      target: "Bad'; Remove-Item C:\\\\*; #",
      desiredValue: true,
    );

    expect(
      (await operation.supports(
        const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        request,
      )).supported,
      isFalse,
    );
  });
}
