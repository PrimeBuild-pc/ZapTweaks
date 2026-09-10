import '../operations/operation.dart';

enum PlanStatus {
  planned,
  running,
  dryRunComplete,
  completed,
  failed,
  rollbackRequired,
  rolledBack,
  rollbackConflict,
  interrupted,
}

enum PlanItemStatus {
  planned,
  snapshotted,
  skipped,
  applying,
  verified,
  pendingRestart,
  failed,
  rolledBack,
  rollbackConflict,
}

class PlanItem {
  PlanItem({
    required this.operationId,
    required this.request,
    required this.before,
    this.status = PlanItemStatus.planned,
    this.snapshot,
    this.written,
    this.error,
  });

  final String operationId;
  final OperationRequest request;
  final OperationState before;
  PlanItemStatus status;
  OperationSnapshot? snapshot;
  OperationState? written;
  String? error;
}

class OperationPlan {
  OperationPlan({
    required this.id,
    required this.createdAt,
    required this.user,
    required this.appVersion,
    required this.windowsBuild,
    required this.items,
    this.status = PlanStatus.planned,
    this.restartRequired = false,
  });

  final String id;
  final DateTime createdAt;
  final String user;
  final String appVersion;
  final int windowsBuild;
  final List<PlanItem> items;
  PlanStatus status;
  bool restartRequired;
}
