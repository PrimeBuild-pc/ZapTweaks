import 'dart:io';

import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_setting_configure_operation.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

Future<void> main() async {
  if (!Platform.isWindows) throw UnsupportedError('Windows only.');
  final service = WindowsPowerSchemeService();
  final operation = PowerSettingConfigureOperation(service);
  final schemeId = service.activeSchemeId;
  final setting = service
      .enumerateSettings(schemeId)
      .firstWhere(
        (item) =>
            item.minimum != null &&
            item.maximum != null &&
            item.minimum! < item.maximum! &&
            (item.increment ?? 1) > 0 &&
            item.minimum! + (item.increment ?? 1) <= item.maximum!,
      );
  final increment = setting.increment ?? 1;
  final changedAc = setting.value.ac == setting.minimum
      ? setting.minimum! + increment
      : setting.minimum!;
  final request = OperationRequest(
    operationId: operation.id,
    target: schemeId,
    desiredValue: <String, int>{'ac': changedAc, 'dc': setting.value.dc},
    parameters: <String, Object?>{
      'subgroupId': setting.subgroupId,
      'settingId': setting.settingId,
    },
  );
  final support = await operation.supports(
    const OperationContext(windowsBuild: 26100, edition: 'Pro'),
    request,
  );
  if (!support.supported) {
    throw StateError(support.reason ?? 'Generic power setting unsupported.');
  }
  final snapshot = await operation.captureSnapshot(request);
  try {
    await operation.apply(request);
    final observed = await operation.verify(request);
    final written = Map<String, Object?>.from(observed.value! as Map);
    if (written['ac'] != changedAc || written['dc'] != setting.value.dc) {
      throw StateError(
        'Power setting verification failed: ${observed.toJson()}',
      );
    }
    stdout.writeln(
      'SETTING=${setting.name} RANGE=${setting.minimum}-${setting.maximum} STEP=$increment ${setting.units ?? ''}',
    );
    stdout.writeln('APPLIED=${observed.toJson()}');
  } finally {
    await operation.rollback(request, snapshot);
    final restored = await operation.inspect(request);
    if (!restored.sameValue(snapshot.expectedAfterRollback)) {
      throw StateError(
        'Power rollback verification failed: ${restored.toJson()}',
      );
    }
    stdout.writeln('RESTORED=${restored.toJson()}');
  }
}
