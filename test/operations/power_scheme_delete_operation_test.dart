import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_scheme_delete_operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/power_plan_file_service.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

class _Schemes implements PowerSchemeManagement {
  bool exists = true;
  @override
  List<PowerSchemeInfo> enumerate() => exists
      ? const <PowerSchemeInfo>[
          PowerSchemeInfo(
            id: '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}',
            name: 'Custom',
            active: false,
          ),
        ]
      : const <PowerSchemeInfo>[];
  @override
  String duplicateScheme(String schemeId, String name) =>
      throw UnimplementedError();
  @override
  void deleteScheme(String schemeId) => exists = false;
  @override
  void renameScheme(String schemeId, String name) {}
}

class _Files extends PowerPlanFileService {
  _Files(this.state)
    : super(
        processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
        schemes: state,
      );
  final _Schemes state;
  @override
  Future<File> exportScheme(String schemeId, File destination) async {
    await destination.parent.create(recursive: true);
    return destination.writeAsBytes(<int>[1]);
  }

  @override
  Future<String> importScheme(
    File source,
    Directory stagingDirectory, {
    String? schemeId,
  }) async {
    state.exists = true;
    return schemeId!;
  }
}

void main() {
  test(
    'power scheme deletion exports before mutation and restores by GUID',
    () async {
      final schemes = _Schemes();
      final operation = PowerSchemeDeleteOperation(
        files: _Files(schemes),
        schemes: schemes,
      );
      const request = OperationRequest(
        operationId: 'power.scheme.delete',
        target: '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}',
        desiredValue: null,
      );
      final snapshot = await operation.captureSnapshot(request);
      addTearDown(() async {
        final backup = File(snapshot.data['backupPath']! as String);
        if (await backup.exists()) await backup.delete();
      });
      await operation.apply(request);
      expect((await operation.verify(request)).kind, OperationStateKind.absent);
      await operation.rollback(request, snapshot);
      expect((await operation.inspect(request)).value, isTrue);
    },
  );
}
