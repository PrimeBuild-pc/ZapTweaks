import 'dart:io';

import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_setting_operation.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

Future<void> main() async {
  if (!Platform.isWindows) throw UnsupportedError('Windows only.');
  final service = WindowsPowerSchemeService();
  final operation = PowerSettingOperation(
    id: 'power_max_processor_state',
    titleKey: 'title',
    descriptionKey: 'description',
    destination: 'Gaming & Performance',
    subgroupId: '54533251-82be-4824-96c1-47b60b740d00',
    settingId: 'bc5038f7-23e0-4960-96da-33abaf5935ec',
    store: service,
  );
  final before = await operation.inspect(
    const OperationRequest(
      operationId: 'power_max_processor_state',
      desiredValue: <String, int>{'ac': 100, 'dc': 100},
    ),
  );
  final values = Map<String, Object?>.from(before.value! as Map);
  final currentAc = values['ac']! as int;
  final currentDc = values['dc']! as int;
  final changed = currentAc == 100 ? 99 : 100;
  final request = OperationRequest(
    operationId: operation.id,
    desiredValue: <String, int>{'ac': changed, 'dc': currentDc},
  );
  final snapshot = await operation.captureSnapshot(request);
  try {
    await operation.apply(request);
    final observed = await operation.verify(request);
    final written = Map<String, Object?>.from(observed.value! as Map);
    if (written['ac'] != changed || written['dc'] != currentDc) {
      throw StateError(
        'Power setting verification failed: ${observed.toJson()}',
      );
    }
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
