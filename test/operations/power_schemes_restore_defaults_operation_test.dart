import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_schemes_restore_defaults_operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/power_plan_file_service.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

const custom = '{11111111-1111-1111-1111-111111111111}';
const second = '{22222222-2222-2222-2222-222222222222}';
const balanced = '{381b4222-f694-41f0-9685-ff5bb260df2e}';

class _Schemes implements PowerSchemeAdministration {
  _Schemes(this.ids, this.active);
  Set<String> ids;
  String active;

  @override
  String get activeSchemeId => active;
  @override
  List<PowerSettingInfo> enumerateSettings(String schemeId) =>
      const <PowerSettingInfo>[];
  @override
  List<PowerSchemeInfo> enumerate() => ids
      .map((id) => PowerSchemeInfo(id: id, name: id, active: id == active))
      .toList();
  @override
  String duplicateScheme(String schemeId, String name) {
    const id = '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}';
    ids.add(id);
    return id;
  }

  @override
  void setActiveScheme(String schemeId) => active = schemeId;
  @override
  void deleteScheme(String schemeId) => ids.remove(schemeId);
  @override
  void renameScheme(String schemeId, String name) {}
  @override
  PowerSettingValue readSetting(
    String schemeId,
    String subgroupId,
    String settingId,
  ) => const PowerSettingValue(ac: 0, dc: 0);
  @override
  void writeSetting(
    String schemeId,
    String subgroupId,
    String settingId,
    PowerSettingValue value,
  ) {}
}

class _Files extends PowerPlanFileService {
  _Files(this.target)
    : super(
        processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
        schemes: target,
      );
  final _Schemes target;

  @override
  Future<File> exportScheme(String schemeId, File destination) async {
    await destination.writeAsString(schemeId);
    return destination;
  }

  @override
  Future<String> importScheme(
    File source,
    Directory stagingDirectory, {
    String? schemeId,
  }) async {
    await stagingDirectory.create(recursive: true);
    target.ids.add(schemeId!);
    return schemeId;
  }
}

void main() {
  const request = OperationRequest(
    operationId: 'power.schemes.restore_defaults',
    desiredValue: true,
  );

  test('default restore backs up and exactly restores all schemes', () async {
    final backupRoot = await Directory.systemTemp.createTemp('zap-power-all-');
    addTearDown(() => backupRoot.delete(recursive: true));
    final schemes = _Schemes(<String>{custom, second}, custom);
    final operation = PowerSchemesRestoreDefaultsOperation(
      files: _Files(schemes),
      schemes: schemes,
      backupRoot: backupRoot,
      secureDirectory: (_) async {},
      processRunner: ProcessRunner(
        processRunDelegate:
            (executable, arguments, {runInShell = false}) async {
              schemes
                ..ids = <String>{balanced}
                ..active = balanced;
              return ProcessResult(1, 0, '', '');
            },
      ),
    );

    final snapshot = await operation.captureSnapshot(request);
    await operation.apply(request);
    expect(
      (await operation.verify(request)).kind,
      OperationStateKind.configured,
    );

    await operation.rollback(request, snapshot);
    expect(schemes.ids, <String>{custom, second});
    expect(schemes.active, custom);
    expect(backupRoot.listSync(), isEmpty);
  });

  test('default restore rejects requests with caller parameters', () async {
    final schemes = _Schemes(<String>{balanced}, balanced);
    final operation = PowerSchemesRestoreDefaultsOperation(
      files: _Files(schemes),
      schemes: schemes,
      backupRoot: Directory.systemTemp,
      secureDirectory: (_) async {},
      processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
    );
    final support = await operation.supports(
      const OperationContext(windowsBuild: 26100, edition: 'Pro'),
      const OperationRequest(
        operationId: 'power.schemes.restore_defaults',
        desiredValue: true,
        parameters: <String, Object?>{'force': true},
      ),
    );
    expect(support.supported, isFalse);
  });
}
