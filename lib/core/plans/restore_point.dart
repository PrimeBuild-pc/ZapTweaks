import '../operations/operation.dart';
import 'operation_plan.dart';

/// Creates a restore point with `system.restore_point.create`. Returns null
/// when it was created, otherwise why not: callers stop and offer to turn
/// on System Protection, never carry on without one.
Future<String?> createRestorePoint(
  Future<OperationPlan> Function(List<OperationRequest> requests) execute, {
  required String description,
  bool enableProtection = false,
}) async {
  try {
    final plan = await execute(<OperationRequest>[
      OperationRequest(
        operationId: 'system.restore_point.create',
        desiredValue: true,
        parameters: <String, Object?>{
          'description': description,
          'enableProtection': enableProtection,
        },
      ),
    ]);
    final item = plan.items.single;
    if (plan.status == PlanStatus.dryRunComplete ||
        item.status == PlanItemStatus.verified) {
      return null;
    }
    return item.error ?? item.status.name;
  } catch (error) {
    return '$error';
  }
}
