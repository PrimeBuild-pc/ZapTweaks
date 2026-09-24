import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_setting_configure_operation.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

const scheme = '11111111-1111-1111-1111-111111111111';
const subgroup = '22222222-2222-2222-2222-222222222222';
const setting = '33333333-3333-3333-3333-333333333333';

class _Schemes implements PowerSchemeAdministration {
  _Schemes({this.overrideInfo});

  final PowerSettingInfo? overrideInfo;
  PowerSettingValue value = const PowerSettingValue(ac: 40, dc: 30);
  String active = scheme;

  @override
  String get activeSchemeId => active;
  @override
  List<PowerSettingInfo> enumerateSettings(String schemeId) =>
      <PowerSettingInfo>[
        overrideInfo ??
            PowerSettingInfo(
              subgroupId: subgroup,
              subgroupName: 'Processor',
              settingId: setting,
              name: 'Bounded setting',
              description: 'Test',
              value: value,
              minimum: 0,
              maximum: 100,
              increment: 5,
              units: '%',
            ),
      ];
  @override
  PowerSettingValue readSetting(
    String schemeId,
    String subgroupId,
    String settingId,
  ) => value;
  @override
  void writeSetting(
    String schemeId,
    String subgroupId,
    String settingId,
    PowerSettingValue value,
  ) => this.value = value;
  @override
  void setActiveScheme(String schemeId) => active = schemeId;
  @override
  List<PowerSchemeInfo> enumerate() => const <PowerSchemeInfo>[];
  @override
  String duplicateScheme(String schemeId, String name) =>
      throw UnimplementedError();
  @override
  void renameScheme(String schemeId, String name) {}
  @override
  void deleteScheme(String schemeId) {}
}

void main() {
  const context = OperationContext(windowsBuild: 26100, edition: 'Pro');

  test(
    'generic power editor validates live bounds and rolls back exactly',
    () async {
      final schemes = _Schemes();
      final operation = PowerSettingConfigureOperation(schemes);
      const request = OperationRequest(
        operationId: 'power.setting.configure',
        target: scheme,
        desiredValue: <String, int>{'ac': 75, 'dc': 50},
        parameters: <String, Object?>{
          'subgroupId': subgroup,
          'settingId': setting,
        },
      );

      expect((await operation.supports(context, request)).supported, isTrue);
      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);
      expect(schemes.value.ac, 75);
      expect(schemes.value.dc, 50);
      await operation.rollback(request, snapshot);
      expect(schemes.value.ac, 40);
      expect(schemes.value.dc, 30);
    },
  );

  test('enumerated settings are editable without numeric bounds', () async {
    final schemes = _Schemes(
      overrideInfo: PowerSettingInfo(
        subgroupId: subgroup,
        subgroupName: 'Wireless',
        settingId: setting,
        name: 'Power saving mode',
        description: 'Test',
        value: const PowerSettingValue(ac: 0, dc: 2),
        possibleValues: const <int, String>{
          0: 'Maximum performance',
          1: 'Low saving',
          2: 'Medium saving',
          3: 'Maximum saving',
        },
      ),
    );
    final operation = PowerSettingConfigureOperation(schemes);
    const request = OperationRequest(
      operationId: 'power.setting.configure',
      target: scheme,
      desiredValue: <String, int>{'ac': 1, 'dc': 3},
      parameters: <String, Object?>{
        'subgroupId': subgroup,
        'settingId': setting,
      },
    );

    expect((await operation.supports(context, request)).supported, isTrue);
    await operation.apply(request);
    expect(schemes.value.ac, 1);
    expect(schemes.value.dc, 3);
  });

  test(
    'generic power editor rejects values outside live bounds or increments',
    () async {
      final operation = PowerSettingConfigureOperation(_Schemes());
      for (final value in <int>[101, 42]) {
        final support = await operation.supports(
          context,
          OperationRequest(
            operationId: operation.id,
            target: scheme,
            desiredValue: <String, int>{'ac': value, 'dc': 50},
            parameters: const <String, Object?>{
              'subgroupId': subgroup,
              'settingId': setting,
            },
          ),
        );
        expect(support.supported, isFalse);
      }
    },
  );
}
