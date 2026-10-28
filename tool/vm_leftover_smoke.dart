// VM only (NeuroTune-W11): finds and removes the leftovers planted by the
// guest setup for "ZTTest Inno" (machine) and "ZTTest User" (user), and checks
// that links are never followed. Prints CLEAN=true on success.
import 'dart:io';

import 'package:script_utility/core/operations/leftover_removal_operation.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/features/apps/application/leftover_scanner.dart';

Future<void> main() async {
  final failures = <String>[];
  void check(bool ok, String what) {
    stdout.writeln('${ok ? 'OK  ' : 'FAIL'} $what');
    if (!ok) failures.add(what);
  }

  final env = Platform.environment;
  for (final (query, machine) in [
    (
      LeftoverQuery(
        name: 'ZTTest Inno 1.0 (x64)',
        installLocation: '${env['ProgramFiles']}\\ZTTest\\ZTTest_Inno',
        uninstallKey: r'HKLM\64\ZTTest_Inno',
      ),
      true,
    ),
    (
      LeftoverQuery(
        name: 'ZTTest User',
        installLocation: '${env['LOCALAPPDATA']}\\ZTTest_User',
        uninstallKey: r'HKCU\64\ZTTest_User',
      ),
      false,
    ),
  ]) {
    final found = await scanLeftovers(ProcessRunner.shared, query);
    for (final item in found) {
      stdout.writeln(
        '  ${item.confidence.name.padRight(6)} ${item.machine ? 'M' : 'U'} ${item.kind.name.padRight(12)} ${item.path}',
      );
    }
    final wanted = machine
        ? <LeftoverKind>{
            LeftoverKind.folder,
            LeftoverKind.registryKey,
            LeftoverKind.runValue,
            LeftoverKind.shortcut,
            LeftoverKind.task,
            LeftoverKind.firewallRule,
          }
        : <LeftoverKind>{
            LeftoverKind.folder,
            LeftoverKind.registryKey,
            LeftoverKind.shortcut,
          };
    check(
      wanted.difference({for (final i in found) i.kind}).isEmpty,
      '${query.name}: every planted kind found',
    );
    for (final context in [true, false]) {
      final items = found
          .where(
            (i) =>
                i.machine == context && i.confidence != LeftoverConfidence.low,
          )
          .map((i) => i.toJson())
          .toList();
      if (items.isEmpty) continue;
      final op = LeftoverRemovalOperation(machine: context);
      final request = OperationRequest(
        operationId: op.id,
        desiredValue: false,
        parameters: <String, Object?>{'items': items},
      );
      final support = await op.supports(
        const OperationContext(windowsBuild: 26100, edition: 'Pro'),
        request,
      );
      check(
        support.supported,
        '${query.name}: request valid (${support.reason})',
      );
      try {
        await op.apply(request);
      } catch (error) {
        stdout.writeln('  APPLY_ERROR=$error');
      }
      final state = await op.verify(request);
      final left = state.value == true ? state.message : '';
      check(
        left == '',
        '${query.name}: removed (${context ? 'machine' : 'user'}) left=$left',
      );
    }
  }

  check(
    File(r'C:\Windows\win.ini').existsSync(),
    'junction inside a removed folder did not take its target',
  );
  final trap = LeftoverRemovalOperation(machine: true);
  final trapRequest = OperationRequest(
    operationId: trap.id,
    desiredValue: false,
    parameters: const <String, Object?>{
      'items': [
        {'kind': 'folder', 'path': r'C:\ProgramData\ZTTrap\Victim'},
      ],
    },
  );
  try {
    await trap.apply(trapRequest);
    check(false, 'parent junction refused');
  } catch (error) {
    check(
      '$error'.contains('Link, junction'),
      'parent junction refused ($error)',
    );
  }
  check(
    Directory(r'C:\ZTVictim\Victim').existsSync(),
    'junction target untouched',
  );
  stdout.writeln('CLEAN=${failures.isEmpty}');
  exitCode = failures.isEmpty ? 0 : 1;
}
