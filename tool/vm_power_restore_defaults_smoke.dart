import 'dart:io';

import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_schemes_restore_defaults_operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/power_plan_file_service.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

Future<void> main() async {
  final schemes = WindowsPowerSchemeService();
  final runner = ProcessRunner.shared;
  final backupRoot = Directory(
    '${Platform.environment['TEMP']}${Platform.pathSeparator}ZapTweaksPowerDefaultsSmoke',
  );
  final operation = PowerSchemesRestoreDefaultsOperation(
    files: PowerPlanFileService(processRunner: runner, schemes: schemes),
    schemes: schemes,
    processRunner: runner,
    backupRoot: backupRoot,
  );
  const request = OperationRequest(
    operationId: 'power.schemes.restore_defaults',
    desiredValue: true,
  );
  final before = schemes.enumerate();
  final active = schemes.activeSchemeId;
  final snapshot = await operation.captureSnapshot(request);
  try {
    await operation.apply(request);
    final applied = await operation.verify(request);
    stdout.writeln('APPLIED=${applied.toJson()}');
  } finally {
    await operation.rollback(request, snapshot);
  }
  final after = schemes.enumerate();
  final clean =
      before
          .map((item) => item.id)
          .toSet()
          .containsAll(after.map((item) => item.id)) &&
      after
          .map((item) => item.id)
          .toSet()
          .containsAll(before.map((item) => item.id)) &&
      active == schemes.activeSchemeId;
  stdout.writeln('BEFORE=${before.length} AFTER=${after.length}');
  stdout.writeln('ACTIVE=${schemes.activeSchemeId}');
  stdout.writeln('CLEAN=$clean');
  if (await backupRoot.exists()) await backupRoot.delete(recursive: true);
  if (!clean) throw StateError('Power scheme rollback mismatch.');
}
