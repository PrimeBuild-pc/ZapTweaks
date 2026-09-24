import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:script_utility/features/power/presentation/power_plans_page.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

void main() {
  test('PowrProf enumerates schemes and marks exactly one active', () {
    if (!Platform.isWindows) return;

    final schemes = WindowsPowerSchemeService().enumerate();

    expect(schemes, isNotEmpty);
    expect(schemes.where((scheme) => scheme.active), hasLength(1));
    expect(schemes.every((scheme) => scheme.id.isNotEmpty), isTrue);
    expect(schemes.every((scheme) => scheme.name.isNotEmpty), isTrue);
  });

  test(
    'PowrProf enumerates setting metadata without unhiding Windows UI entries',
    () {
      if (!Platform.isWindows) return;

      final service = WindowsPowerSchemeService();
      final settings = service.enumerateSettings(service.activeSchemeId);

      expect(settings, isNotEmpty);
      expect(
        settings.every((setting) => setting.subgroupId.isNotEmpty),
        isTrue,
      );
      expect(settings.every((setting) => setting.settingId.isNotEmpty), isTrue);
      expect(settings.every((setting) => setting.name.isNotEmpty), isTrue);
      expect(
        settings.any(
          (setting) =>
              setting.minimum != null &&
              setting.maximum != null &&
              setting.minimum! <= setting.maximum!,
        ),
        isTrue,
      );
      expect(
        settings.any((setting) => setting.possibleValues.isNotEmpty),
        isTrue,
      );
      final wirelessMode = settings.singleWhere(
        (setting) =>
            setting.settingId.toLowerCase() ==
            '{12bbebe6-58d6-4636-95bb-3217ef867c1a}',
      );
      expect(wirelessMode.possibleValues, hasLength(4));
    },
  );

  test(
    'setting inventory crosses the isolate boundary used by the UI',
    () async {
      final schemeId = WindowsPowerSchemeService().activeSchemeId;
      final settings = await loadPowerSettingsInBackground(schemeId);

      expect(settings, isNotEmpty);
      expect(settings.every((setting) => setting.settingId.isNotEmpty), isTrue);
    },
  );

  test('PowrProf reads AC and DC values from the active scheme', () {
    if (!Platform.isWindows) return;

    final service = WindowsPowerSchemeService();
    final value = service.readSetting(
      service.activeSchemeId,
      '54533251-82be-4824-96c1-47b60b740d00',
      '893dee8e-2bef-41e0-89c6-b55d0929964c',
    );

    expect(value.ac, inInclusiveRange(0, 100));
    expect(value.dc, inInclusiveRange(0, 100));
  });
}
