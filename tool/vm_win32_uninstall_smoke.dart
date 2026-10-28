// VM only (NeuroTune-W11): uninstalls the fake "ZTTest" programs created by
// build/run_vm_uninstall_smoke.ps1 through the real operation, and checks that
// entries pointing at a shell are never launched. Prints CLEAN=true on success.
import 'dart:io';

import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/restore_point_operation.dart';
import 'package:script_utility/core/operations/win32_uninstall_operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/uninstall_command.dart';
import 'package:script_utility/features/apps/application/windows_app_inventory_service.dart';

Future<void> main() async {
  if (!Platform.isWindows) throw UnsupportedError('Windows only.');
  final failures = <String>[];
  void check(bool ok, String what) {
    stdout.writeln('${ok ? 'OK  ' : 'FAIL'} $what');
    if (!ok) failures.add(what);
  }

  final restore = RestorePointOperation(processRunner: ProcessRunner.shared);
  final restoreRequest = OperationRequest(
    operationId: restore.id,
    desiredValue: true,
    parameters: <String, Object?>{
      'description': 'ZapTweaks VM smoke',
      'enableProtection': Platform.environment['ZT_ENABLE_PROTECTION'] == '1',
    },
  );
  try {
    await restore.apply(restoreRequest);
    check(
      (await restore.verify(restoreRequest)).value == true,
      'restore point created and found by description',
    );
  } catch (error) {
    stdout.writeln('RESTORE_POINT_ERROR=$error');
    check(
      Platform.environment['ZT_ENABLE_PROTECTION'] != '1',
      'restore point fails only while protection is off',
    );
  }

  if (Platform.environment['ZT_RESTORE_ONLY'] == '1') {
    stdout.writeln('CLEAN=${failures.isEmpty}');
    exitCode = failures.isEmpty ? 0 : 1;
    return;
  }

  final inventory = await WindowsAppInventoryService(
    processRunner: ProcessRunner.shared,
  ).scanWin32();
  final tests = inventory.packages
      .where((app) => app.name.startsWith('ZTTest '))
      .toList();
  stdout.writeln(
    'FOUND=${tests.map((a) => '${a.name}@${a.packageId}').join('; ')}',
  );
  check(tests.length >= 5, 'all fake programs listed by the inventory');

  for (final app in tests) {
    final machine = app.uninstall!.hive == 'HKLM';
    final operation = Win32UninstallOperation(
      machine: machine,
      waitLimit: const Duration(seconds: 30),
    );
    final request = OperationRequest(
      operationId: operation.id,
      target: app.packageId,
      desiredValue: false,
      parameters: const <String, Object?>{'silent': true},
    );
    final plan = planUninstall(
      app.uninstall!,
      environment: Platform.environment,
      fileExists: (path) => File(path).existsSync(),
    );
    final unsafe = app.name.contains('Unsafe');
    try {
      await operation.apply(request);
      final gone = (await operation.verify(request)).value == false;
      check(!unsafe && gone, '${app.name}: uninstalled (${plan.runtimeType})');
    } catch (error) {
      check(unsafe, '${app.name}: refused ($error)');
    }
  }

  final marker = File(r'C:\ZTTestPwned.txt');
  check(!marker.existsSync(), 'no unsafe command ever ran');
  final log = File(r'C:\ZTTestLog\args.log');
  final args = log.existsSync() ? log.readAsStringSync() : '';
  stdout.writeln('ARGS=\n$args');
  check(args.contains('/VERYSILENT'), 'Inno-style uninstaller got /VERYSILENT');
  check(args.contains('/S'), 'NSIS-style uninstaller got /S');
  stdout.writeln('CLEAN=${failures.isEmpty}');
  exitCode = failures.isEmpty ? 0 : 1;
}
