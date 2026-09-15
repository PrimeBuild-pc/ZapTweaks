import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_scheme_activation_operation.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

class _PowerStore implements PowerSchemeStore {
  String current = '{381b4222-f694-41f0-9685-ff5bb260df2e}';
  @override
  String get activeSchemeId => current;
  @override
  void setActiveScheme(String schemeId) => current = schemeId;
  @override
  PowerSettingValue readSetting(
    String schemeId,
    String subgroupId,
    String settingId,
  ) => const PowerSettingValue(ac: 0, dc: 0);
  @override
  void writeSetting(
    String schemeId,
    String subgroupId,
    String settingId,
    PowerSettingValue value,
  ) {}
}

void main() {
  test(
    'active power scheme round trip restores the exact original GUID',
    () async {
      final store = _PowerStore();
      final operation = PowerSchemeActivationOperation(store: store);
      const request = OperationRequest(
        operationId: 'power.scheme.activate',
        desiredValue: '{a1841308-3541-4fab-bc81-f71556f20b4a}',
      );

      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);
      expect((await operation.verify(request)).value, request.desiredValue);
      await operation.rollback(request, snapshot);
      expect(store.activeSchemeId, '{381b4222-f694-41f0-9685-ff5bb260df2e}');
    },
  );

  test('active power scheme rejects non-canonical identifiers', () async {
    final operation = PowerSchemeActivationOperation(store: _PowerStore());
    const request = OperationRequest(
      operationId: 'power.scheme.activate',
      desiredValue: 'balanced',
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
