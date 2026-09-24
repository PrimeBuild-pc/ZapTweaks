import 'dart:io';
import 'dart:isolate';

import 'package:script_utility/platform/windows/power_scheme_service.dart';

Future<void> main() async {
  if (!Platform.isWindows) throw UnsupportedError('Windows only.');
  final schemes = WindowsPowerSchemeService().enumerate();
  for (final scheme in schemes) {
    final settings = await Isolate.run(
      () => WindowsPowerSchemeService().enumerateSettings(scheme.id),
    );
    final editable = settings.where(
      (item) =>
          item.possibleValues.isNotEmpty ||
          (item.minimum != null && item.maximum != null),
    );
    final unknown = settings.where(
      (item) =>
          item.possibleValues.isEmpty &&
          (item.minimum == null || item.maximum == null),
    );
    stdout.writeln(
      'DETAILS=${scheme.id}:${settings.length} '
      'EDITABLE=${editable.length} '
      'ENUMERATED=${settings.where((item) => item.possibleValues.isNotEmpty).length} '
      'UNKNOWN=${unknown.length}',
    );
    for (final item in unknown) {
      stdout.writeln(
        'UNKNOWN_SETTING=${item.subgroupName}/${item.name}/${item.settingId}',
      );
    }
  }
  final active = schemes.singleWhere((item) => item.active);
  for (final scheme in schemes.where((item) => !item.active)) {
    final results = await Future.wait(<Future<List<PowerSettingInfo>>>[
      Isolate.run(
        () => WindowsPowerSchemeService().enumerateSettings(active.id),
      ),
      Isolate.run(
        () => WindowsPowerSchemeService().enumerateSettings(scheme.id),
      ),
    ]);
    final right = <String, PowerSettingInfo>{
      for (final item in results[1])
        '${item.subgroupId}/${item.settingId}': item,
    };
    final differences = results[0].where((item) {
      final other = right['${item.subgroupId}/${item.settingId}'];
      return other == null ||
          item.value.ac != other.value.ac ||
          item.value.dc != other.value.dc;
    }).length;
    stdout.writeln('COMPARE=${active.id}:${scheme.id}:$differences');
  }
  stdout.writeln('READ_ONLY=true');
}
