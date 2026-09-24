import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/power_plan_file_service.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

class _Schemes implements PowerSchemeInventory {
  bool imported = false;
  @override
  List<PowerSchemeInfo> enumerate() => <PowerSchemeInfo>[
    const PowerSchemeInfo(
      id: '{381b4222-f694-41f0-9685-ff5bb260df2e}',
      name: 'Balanced',
      active: true,
    ),
    if (imported)
      const PowerSchemeInfo(
        id: '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}',
        name: 'Imported',
        active: false,
      ),
  ];
}

void main() {
  test('power plan import stages and removes a frozen copy', () async {
    final directory = await Directory.systemTemp.createTemp('zap-pow-');
    addTearDown(() => directory.delete(recursive: true));
    final source = await File(
      '${directory.path}${Platform.pathSeparator}source.pow',
    ).writeAsBytes(<int>[1, 2, 3]);
    final staging = Directory(
      '${directory.path}${Platform.pathSeparator}stage',
    );
    final schemes = _Schemes();
    final service = PowerPlanFileService(
      schemes: schemes,
      processRunner: ProcessRunner(
        processRunDelegate:
            (executable, arguments, {runInShell = false}) async {
              schemes.imported = true;
              return ProcessResult(1, 0, '', '');
            },
      ),
    );

    final id = await service.importScheme(source, staging);

    expect(id, '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}');
    expect(
      await File('${staging.path}${Platform.pathSeparator}import.pow').exists(),
      isFalse,
    );
  });

  test('power plan import rejects non-POW files before execution', () async {
    final directory = await Directory.systemTemp.createTemp('zap-pow-');
    addTearDown(() => directory.delete(recursive: true));
    final source = File('${directory.path}${Platform.pathSeparator}source.pow');
    await source.writeAsBytes(<int>[1]);
    await source.openWrite(mode: FileMode.append).close();
    final service = PowerPlanFileService(
      schemes: _Schemes(),
      processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
    );
    expect(
      service.importScheme(
        File('${directory.path}${Platform.pathSeparator}source.txt'),
        directory,
      ),
      throwsArgumentError,
    );
  });
}
