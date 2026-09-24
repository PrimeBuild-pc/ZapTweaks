import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_setting_operation.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

class _PowerStore implements PowerSchemeStore {
  @override
  String activeSchemeId = 'balanced';
  final values = <String, PowerSettingValue>{
    'balanced': const PowerSettingValue(ac: 5, dc: 10),
    'gaming': const PowerSettingValue(ac: 20, dc: 30),
  };

  @override
  PowerSettingValue readSetting(
    String schemeId,
    String subgroupId,
    String settingId,
  ) => values[schemeId]!;

  @override
  void setActiveScheme(String schemeId) => activeSchemeId = schemeId;

  @override
  void writeSetting(
    String schemeId,
    String subgroupId,
    String settingId,
    PowerSettingValue value,
  ) => values[schemeId] = value;
}

void main() {
  test(
    'power setting snapshot restores values and the active scheme',
    () async {
      final store = _PowerStore();
      final operation = PowerSettingOperation(
        id: 'power.test',
        titleKey: 'title',
        descriptionKey: 'description',
        destination: 'Gaming & Performance',
        subgroupId: 'subgroup',
        settingId: 'setting',
        store: store,
      );
      const request = OperationRequest(
        operationId: 'power.test',
        target: 'gaming',
        desiredValue: <String, int>{'ac': 100, 'dc': 90},
      );
      final snapshot = await operation.captureSnapshot(request);

      await operation.apply(request);
      expect((await operation.verify(request)).value, <String, int>{
        'ac': 100,
        'dc': 90,
      });
      store.activeSchemeId = 'gaming';
      await operation.rollback(request, snapshot);

      expect(store.values['gaming']!.ac, 20);
      expect(store.values['gaming']!.dc, 30);
      expect(store.activeSchemeId, 'balanced');
    },
  );

  test('power setting rejects incomplete values before mutation', () async {
    final operation = PowerSettingOperation(
      id: 'power.test',
      titleKey: 'title',
      descriptionKey: 'description',
      destination: 'Gaming & Performance',
      subgroupId: 'subgroup',
      settingId: 'setting',
      store: _PowerStore(),
    );

    final support = await operation.supports(
      const OperationContext(windowsBuild: 26100, edition: 'Pro'),
      const OperationRequest(
        operationId: 'power.test',
        desiredValue: <String, int>{'ac': 100},
      ),
    );

    expect(support.supported, isFalse);
  });
}
