import 'package:flutter_test/flutter_test.dart';
import 'package:script_utility/core/operations/operation.dart';
import 'package:script_utility/core/operations/system_repair_operation.dart';
import 'package:script_utility/core/services/process_runner.dart';
import 'package:script_utility/platform/windows/system_repair_service.dart';

class _RepairService extends WindowsRepairService {
  _RepairService(this.verified) : super(processRunner: _UnusedRunner());

  final bool verified;

  @override
  Future<RepairReport> repairComponentStore() async => RepairReport(
    action: 'DISM',
    repairExitCode: 0,
    verificationExitCode: verified ? 0 : 1,
    verified: verified,
  );

  @override
  Future<RepairReport> repairSystemFiles() => repairComponentStore();
}

class _UnusedRunner extends ProcessRunner {
  _UnusedRunner() : super();
}

void main() {
  test('repair action succeeds only after its verification pass', () async {
    final operation = SystemRepairOperation(
      kind: SystemRepairKind.componentStore,
      service: _RepairService(true),
    );
    const request = OperationRequest(
      operationId: 'recovery.dism.restore_health',
      desiredValue: true,
    );

    await operation.apply(request);

    final state = await operation.verify(request);
    expect(state.kind, OperationStateKind.configured);
    expect(state.value, isTrue);
  });

  test('repair action propagates a failed verification', () async {
    final operation = SystemRepairOperation(
      kind: SystemRepairKind.systemFiles,
      service: _RepairService(false),
    );
    const request = OperationRequest(
      operationId: 'recovery.sfc.scan_now',
      desiredValue: true,
    );

    expect(operation.apply(request), throwsStateError);
  });
}
