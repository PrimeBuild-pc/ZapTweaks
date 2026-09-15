import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/power_plan_import_operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/power_plan_file_service.dart';
import 'package:script_utility/platform/windows/power_scheme_service.dart';

class _Schemes implements PowerSchemeManagement {
  String? imported;
  @override
  List<PowerSchemeInfo> enumerate() => <PowerSchemeInfo>[
    if (imported != null)
      PowerSchemeInfo(id: imported!, name: 'Imported', active: false),
  ];
  @override
  String duplicateScheme(String schemeId, String name) =>
      throw UnimplementedError();
  @override
  void renameScheme(String schemeId, String name) {}
  @override
  void deleteScheme(String schemeId) => imported = null;
}

class _Files extends PowerPlanFileService {
  _Files(this.state)
    : super(
        processRunner: ProcessRunner(mode: ProcessExecutionMode.dryRun),
        schemes: state,
      );
  final _Schemes state;
  @override
  Future<String> importScheme(
    File source,
    Directory stagingDirectory, {
    String? schemeId,
  }) async {
    state.imported = schemeId;
    return schemeId!;
  }
}

void main() {
  test(
    'power plan import verifies its assigned GUID and rolls it back',
    () async {
      final source = await File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}zap-test.pow',
      ).writeAsBytes(<int>[1]);
      addTearDown(() => source.delete());
      final schemes = _Schemes();
      final operation = PowerPlanImportOperation(
        files: _Files(schemes),
        schemes: schemes,
      );
      final request = OperationRequest(
        operationId: 'power.scheme.import',
        desiredValue: '{aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa}',
        parameters: <String, Object?>{'sourcePath': source.path},
      );
      final snapshot = await operation.captureSnapshot(request);
      await operation.apply(request);
      expect((await operation.verify(request)).value, request.desiredValue);
      await operation.rollback(request, snapshot);
      expect(
        (await operation.inspect(request)).kind,
        OperationStateKind.absent,
      );
    },
  );
}
